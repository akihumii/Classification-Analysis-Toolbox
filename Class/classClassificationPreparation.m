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
        
        function clfp = detectSpikes(clfp,targetClassData,targetName,type,threshold,sign)
            if isequal(targetName,'dataFiltered')
                targetName = [{'dataFiltered'};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(targetClassData,targetName);
            switch type
                case 'threshold'
                    minDistance = clfp.window(2)*targetClassData.samplingFreq;
                    clfp.burstDetection = detectSpikes(dataValue,minDistance,threshold,sign);
                otherwise
            end                        
            clfp.burstDetection.dataAnalysed = [targetClassData.file,' -> ',dataName];
            clfp.burstDetection.detectionMethod = type;
        end
        
        function clfp = classificationWindowSelection(clfp, targetClassData, targetFieldName)
            [dataValues, dataName] = loadMultiLayerStruct(targetClassData,targetFieldName);
            clfp.selectedWindows = classificationWindowSelection(...
                dataValues,...
                clfp.burstDetection.spikeLocs,...
                clfp.window,...
                targetClassData.samplingFreq);
            if iscell(targetFieldName)
                clfp.selectedWindows.dataProcessed = targetFieldName{1};
            else
                clfp.selectedWindows.dataProcessed = targetFieldName;
            end
        end
        
        function clfp = featureExtraction(clfp,targetField)
            [dataValues, dataName] = loadMultiLayerStruct(clfp,targetField);
            clfp.features = featureExtraction(dataValues);
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
        end
        
    end
    
    methods (Access = protected)
    end
end
