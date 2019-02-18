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
        baselineInfo
    end
    
    properties (Access = private)
        trimMinDistance = 0.3 % seconds
        sortedBaselineMultiplier = [4,3]
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
            
            baseline = getSortedDataBaseline(clfp, dataValue, parameters.signData);
            thresholdValue = getThresholdValue(clfp,baseline, parameters.threshold, clfp.sortedBaselineMultiplier, parameters.signData);
            
            clfp.burstDetection = detectSpikes(dataValue,minDistance,parameters,baseline,thresholdValue); % use middle stream of sorted data to get a rough burst detection threshold
            clfp.baselineInfo = getBaselineFeature(clfp.burstDetection,targetClassData.samplingFreq,targetClassData.dataFiltered.values,parameters.baselineType,targetClassData.dataTKEO.values);  % get the more reliable baseline by using the roughly detected bursts
            
            thresholdValue = getThresholdValue(clfp,clfp.baselineInfo.baselineInfo, parameters.threshold, parameters.threshStdMult, parameters.signData);
            clfp.burstDetection = detectSpikes(dataValue,minDistance,parameters,clfp.baselineInfo.baselineInfo,thresholdValue); % overwrite the roughly gauged ones with the more accurate one 
                        
            clfp.baselineInfo = getBaselineFeature(clfp.burstDetection,targetClassData.samplingFreq,targetClassData.dataFiltered.values,parameters.baselineType,targetClassData.dataTKEO.values);  % update the number of baseline chunks and their corresponding features
            
            clfp.burstDetection.dataAnalysed = [targetClassData.file,' -> ',dataName];
            clfp.burstDetection.detectionMethod = parameters.spikeDetectionType;
            clfp.burstDetection.channelExtractStartingLocs = parameters.channelExtractStartingLocs;
            
            if parameters.padZeroFlag
                clfp = trimShortenedBursts(clfp,dataValue,targetClassData.samplingFreq);
            end
            
        end
        
        function clfp = classificationWindowSelection(clfp, targetClassData, parameters)
            % input: parameters: targetName,burstTrimming,burstTrimmingType
            if isequal(parameters.overlappedWindow,'dataFiltered') || isequal(parameters.overlappedWindow,'dataTKEO')
                parameters.overlappedWindow = [{parameters.overlappedWindow};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(targetClassData,parameters.overlappedWindow);
            
            if parameters.burstTrimming % to trim the bursts
                p = plotFig(targetClassData.time/targetClassData.samplingFreq,[dataValue,targetClassData.dataAll(:,12)],'','','Time(s)','Amplitude(V)',0,1);
                                
                [clfp.burstDetection.spikePeaksValue,clfp.burstDetection.spikeLocs,clfp.burstDetection.burstEndValue,clfp.burstDetection.burstEndLocs,clfp.burstDetection.selectedBurstsIndex] =...
                    deleteBurst(parameters.burstTrimmingType, parameters.burstTrimmingWay, p, targetClassData.time, targetClassData.samplingFreq, clfp.burstDetection.spikePeaksValue,clfp.burstDetection.spikeLocs,clfp.burstDetection.burstEndValue,clfp.burstDetection.burstEndLocs);
            else
                clfp.burstDetection.selectedBurstsIndex = getSelectedBurstsIndex(clfp);
            end
            
            clfp = getBurstInterval(clfp,targetClassData);            

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
%         
%         function clfp = insertBaselineFeature(clfp)
%             clfp = insertBaselineFeature(clfp,clfp.baselineInfo);
%         end

    end
    
    %% Procted methods
    methods (Access = protected)
        function baseline = getSortedDataBaseline(~, data, dataSign)
            colData = size(data,2);
            
            for i = 1:colData
                baseline{i,1} = baselineDetection(dataSign * data(:,i)); % the mean of the data points spanned from 1/4 to 3/4 of the data sorted by amplitude is obtained as baseline
            end
        end
        
        function thresholdValue = getThresholdValue(~, baseline, threshold, threshStdMult, signData)
            colData = length(baseline);
            for i = 1:colData
                if threshold == 0 % if no user input, baseline + parameters.threshStdMult * baselineStandardDeviation will be used as parameters.threshold value
                    if length(threshStdMult) < colData
                        error('Not enough parameters.threshStdMult for all the channels...');
                    else
                        thresholdValue(i,1) = signData * baseline{i,1}.average + threshStdMult(1,i) * baseline{i,1}.stD;
                    end
                elseif length(parameters.threshold) == 1
                    thresholdValue(i,1) = signData * threshold(1,1);
                else
                    thresholdValue(i,1) = signData * threshold(1,i);
                end
            end
        end
        
        function clfp = trimShortenedBursts(clfp,dataValue,samplingFreq)
            minDistance = round(clfp.trimMinDistance * samplingFreq); % minimum distance surrounding the bursts that need to be not zero
            
            numChannel = size(clfp.burstDetection.spikePeaksValue,2);
            dataSize = size(dataValue,1);
            
            for i = 1:numChannel
                numBursts = sum(~isnan(clfp.burstDetection.spikePeaksValue(:,i)));
                deleteFlagTemp = false(numBursts,1);
                for j = 1:numBursts
                    windowCheck = clfp.burstDetection.spikeLocs(j,i) - minDistance :...
                        clfp.burstDetection.burstEndLocs(j,i) + minDistance;
                    windowCheck(windowCheck <= 0 | windowCheck > dataSize) = [];
                    if all(windowCheck <= dataSize) &&...
                            any(dataValue(windowCheck,i) == 0)
                        deleteFlagTemp(j,1) = true;
                    end
                end
                spikePeaksValueTemp{i,1} = clfp.burstDetection.spikePeaksValue(~deleteFlagTemp(:,1),i);
                spikeLocsTemp{i,1} = clfp.burstDetection.spikeLocs(~deleteFlagTemp(:,1),i);
                burstEndValueTemp{i,1} = clfp.burstDetection.burstEndValue(~deleteFlagTemp(:,1),i);
                burstEndLocsTemp{i,1} = clfp.burstDetection.burstEndLocs(~deleteFlagTemp(:,1),i);
                
                if isempty(spikePeaksValueTemp{i,1}); spikePeaksValueTemp{i,1} = nan; end
                if isempty(spikeLocsTemp{i,1}); spikeLocsTemp{i,1} = nan; end
                if isempty(burstEndValueTemp{i,1}); burstEndValueTemp{i,1} = nan; end
                if isempty(burstEndLocsTemp{i,1}); burstEndLocsTemp{i,1} = nan; end
            end
            
            clfp.burstDetection.spikePeaksValue = cell2nanMat(spikePeaksValueTemp);
            clfp.burstDetection.spikeLocs = cell2nanMat(spikeLocsTemp);
            clfp.burstDetection.burstEndValue = cell2nanMat(burstEndValueTemp);
            clfp.burstDetection.burstEndLocs = cell2nanMat(burstEndLocsTemp);
        end
        
        function clfp = getBurstInterval(clfp,targetClassData)
            numChannel = length(targetClassData.channel);
            burstInterval = diff(clfp.burstDetection.spikeLocs,1,1);
            burstInterval = vertcat(burstInterval, nan(1,numChannel)); % for the last set of bursts
            burstInterval(burstInterval<0 | burstInterval > 3*targetClassData.samplingFreq) = nan;

            burstIntervalAllSeconds = burstInterval / targetClassData.samplingFreq;
            clfp.burstDetection.burstInterval = burstInterval;
            clfp.burstDetection.burstIntervalSeconds = burstIntervalAllSeconds;
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
