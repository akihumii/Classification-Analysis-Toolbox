classdef classClassificationPreparation
    % classClassification Classify input signal (clfp represents
    % classificationPreparation)
    %
    % clfp = classClassificationPreparation(file,path,window,trainingRatio)
    %   'window' is optional. Default value = [0.005, 0.4].
    %   'trainingRatio' is optional, but 'window' is essential if a number
    %   is to be keyed in. Default value = 5/8.
    %
    % clfp = detectSpikes(clfp,targetClassData,targetFieldName,type)
    %
    % clfp = classificationWindowSelection(clfp, targetClassData, targetFieldName)
    %   'targetClassData' is the class that contains the data that is to be
    %   processed.
    %   'targetFieldName' is the field name of the data that is to be
    %   processed. If it is a structure, present it as a tall matrix.
    %   Note that filtered data is stored in the structure 'dataFiltered',
    %   in the field 'values'. Thus, ['dataFiltered';'values'] will be the
    %   input here.
    %
    % clfp = featureExtraction(clf,targetField)
    %
    % clfp = classificationGrouping(clf,targetField)
    %
    
    properties
        file
        path
        window
        burstDetection
        selectedWindows
        features
        trainingRatio
        grouping
    end
    
    properties (Access = private)
    end
    
    methods
        function clfp = classClassificationPreparation(varargin)
            if nargin > 2
                clfp.window = varargin{3};
            else
                clfp.window = [0.005,0.4];
            end
            if nargin > 0
                clfp.file = varargin{1};
                clfp.path = varargin{2};
            end
        end
        
        function clfp = detectSpikes(clfp,targetClassData,parameters)
            % input: parameters: targetName,type,threshold,sign,threshStdMult,TKEOStartConsecutivePoints,TKEOEndConsecutivePoints,channelExtractStartingLocs
            if isequal(parameters.dataToBeDetectedSpike,'dataFiltered') || isequal(parameters.dataToBeDetectedSpike,'dataTKEO')
                parameters.dataToBeDetectedSpike = [{parameters.dataToBeDetectedSpike};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(targetClassData,parameters.dataToBeDetectedSpike);
            minDistance = floor(clfp.window * targetClassData.samplingFreq);
            clfp.burstDetection = detectSpikes(dataValue,minDistance,parameters);
            clfp.burstDetection.dataAnalysed = [targetClassData.file,' -> ',dataName];
            clfp.burstDetection.detectionMethod = parameters.spikeDetectionType;
            clfp.burstDetection.channelExtractStartingLocs = parameters.channelExtractStartingLocs;
            
            burstInterval = getBurstInterval(clfp,targetClassData);
            
            burstIntervalAllSeconds = burstInterval / targetClassData.samplingFreq;
            clfp.burstDetection.burstInterval = burstInterval;
            clfp.burstDetection.burstIntervalSeconds = burstIntervalAllSeconds;
        end
        
        function clfp = classificationWindowSelection(clfp, targetClassData, parameters)
            % input: parameters: targetName,burstTrimming,burstTrimmingType
            if isequal(parameters.overlappedWindow,'dataFiltered') || isequal(parameters.overlappedWindow,'dataTKEO')
                parameters.overlappedWindow = [{parameters.overlappedWindow};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(targetClassData,parameters.overlappedWindow);
            
            if parameters.burstTrimming % to trim the bursts
                p = plotFig(targetClassData.time/targetClassData.samplingFreq,dataValue,'','','Time(s)','Amplitude(V)',0,1);
                [clfp.burstDetection.spikePeaksValue,clfp.burstDetection.spikeLocs,clfp.burstDetection.burstEndValue,clfp.burstDetection.burstEndLocs,clfp.burstDetection.selectedBurstsIndex] =...
                    deleteBurst(parameters.burstTrimmingType, p, targetClassData.time, targetClassData.samplingFreq, clfp.burstDetection.spikePeaksValue,clfp.burstDetection.spikeLocs,clfp.burstDetection.burstEndValue,clfp.burstDetection.burstEndLocs);
            else
                clfp.burstDetection.selectedBurstsIndex = getSelectedBurstsIndex(clfp);
            end
            
            clfp.selectedWindows = getPointsWithinRange(...
                targetClassData.time,...
                dataValue,...
                clfp.burstDetection.spikeLocs,...
                clfp.burstDetection.burstEndLocs,...
                [0,0],...
                targetClassData.samplingFreq, 0);
        end
        
        function clfp = pcaCleanData(clfp)
            clfp.selectedWindows.burst = pcaCleanData(clfp.selectedWindows.burst);
            clfp.selectedWindows.burstMean = nanmean(clfp.selectedWindows.burst,2);
            numSamplePoints = size(clfp.selectedWindows.burst,1);
            clfp.selectedWindows.xAxisValues = clfp.selectedWindows.xAxisValues(1:numSamplePoints,:,:);
        end

        function clfp = featureExtraction(clfp,samplingFreq,targetField)
            [dataValues, dataName] = loadMultiLayerStruct(clfp,targetField);
            clfp.features = featureExtraction(dataValues,samplingFreq);
            clfp.features.dataAnalysed = [clfp.file, ' -> ', dataName];
        end
        
        function clfp = classificationGrouping(clfp,targetField,class,trainingRatio)
            if nargin < 4
                clfp.trainingRatio = 5/8;
            else
                clfp.trainingRatio = trainingRatio;
            end
            clfp.grouping = classificationGrouping(clfp.features, clfp.trainingRatio, class, targetField);
            clfp.grouping.class = class;
            clfp.grouping.targetField = targetField;
        end
        
        function clfp = getBaselineFeature(clfp,samplingFreq)
            baselineInfo = getBaselineFeature(clfp.burstDetection,samplingFreq);
            clfp = insertBaselineFeature(clfp,baselineInfo);
        end

    end
    
    methods (Access = protected)
        function burstInterval = getBurstInterval(clfp,targetClassData)
            numChannel = length(targetClassData.channel);
            burstInterval = diff(clfp.burstDetection.spikeLocs,1,1);
            burstInterval = vertcat(burstInterval, nan(1,numChannel)); % for the last set of bursts
            burstInterval(burstInterval<0 | burstInterval > 3*targetClassData.samplingFreq) = nan;
        end
        
        function selectedBurstsIndex = getSelectedBurstsIndex(clfp)
            numChannel = size(clfp.burstDetection.spikePeaksValue,2);
            selectedBurstsIndex = cell(numChannel,1);
            for i = 1:numChannel
                spikePeaksValueTemp = clfp.burstDetection.spikePeaksValue(:,i);
                if all(isnan(spikePeaksValueTemp))
                    selectedBurstsIndex{i,1} = 0;
                else
                    selectedBurstsIndex{i,1} = 1:(sum(~isnan(spikePeaksValueTemp)));
                end
            end
        end
        
    end
end
