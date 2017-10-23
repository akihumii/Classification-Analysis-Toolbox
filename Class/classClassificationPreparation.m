classdef classClassificationPreparation
    % classClassification Classify input signal
    % function clf = classClassificationPreparation(file,path,window,trainingRatio)
    %     'window' is optional. Default value = [0.005, 0.4].
    %     'trainingRatio' is optional. Default value = 5/8.
    % function clf = selectBurst(clf,targetClassData,targetFieldName,type)
    % function clf = featureExtraction(clf,targetField)
    % function clf = classify(clf)
    % clf = classificationGrouping(clf,targetField)
    
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
        
        function clfp = detectSpikes(clfp,targetClassData,targetFieldName,type)
            switch type
                case 'threshold'
                    minDistance = clfp.window(2)*targetClassData.samplingFreq;
                    clfp.burstDetection = detectSpikes(targetClassData.(targetFieldName),minDistance);
                otherwise
            end                        
            clfp.burstDetection.dataAnalysed = [targetClassData.file,' -> ',targetFieldName];
            errorShow(targetFieldName, 'targetFieldName', 'char');
            clfp.burstDetection.detectionMethod = type;
        end
        
        function clfp = classificationWindowSelection(clfp, targetClassData, targetFieldName)
            [dataValues, dataName] = loadMultiLayerStruct(targetClassData,[{targetFieldName};{'values'}]);
            clfp.selectedWindows = ...
                classificationWindowSelection(dataValues,...
                clfp.burstDetection.spikeLocs,...
                clfp.window,...
                targetClassData.samplingFreq);
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
