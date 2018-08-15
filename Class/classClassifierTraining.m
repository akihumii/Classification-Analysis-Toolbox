classdef classClassifierTraining
    % trainClassifier Train the classifier to use in analyzeFeatures
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    properties
        featureIndex
        classificationOutput
        accuracyBasicParameter
        accuracyInfo
        maxFeatureCombo
        classifierTitle
        classifierFullTitle
        accuracy
        accuracyStde
        accuracyMax
    end
    
    properties (Access = private)
        trainingRatio = 0.625;
        % featureIndex = [2,3,7]; % input the feature index for the feature combination
        numFeatures = 8;
        maxNumFeaturesInCombination = 2; % maximum nubmer of features used in combinations
        classificationRepetition = 1000; % number of repetition of the classification with randomly assigned training set and testing set
    end
    
    methods (Access = public)
        function obj = setClassifier(obj,signalInfo)
            obj.classifierTitle = 'Different Day'; % it can be 'Different Speed','Different Day','Active EMG'
            obj.classifierFullTitle = [obj.classifierTitle,' ('];
            switch obj.classifierTitle
                case 'Different Speed'
                    fileType = featursInfo.fileSpeed;
                case 'Different Day'
                    fileType = signalInfo(:).fileDate;
                case 'Active EMG'
                    fileType = [{'Active'};{'Non Active'}];
            end
            for i = 1:length(fileType)
                obj.classifierFullTitle = [obj.classifierFullTitle,' ',char(fileType)];
            end
            obj.classifierFullTitle = [obj.classifierFullTitle,' )'];
        end
        
        function y = trainClassifier(obj,featuresInfo,displayInfo)
            if displayInfo.showHistFit||displayInfo.saveHistFit||displayInfo.showAccuracy||displayInfo.saveAccuracy
                popMsg('Training classifiers...');
                
                for i = 1:obj.maxNumFeaturesInCombination
                    obj.featureIndex{i,1} = nchoosek(1:obj.numFeatures,i); % n choose k
                    numCombination = size(obj.featureIndex{i,1},1); % number of combination
                    for j = 1:numCombination
                        y.classificationOutput{i,1}(j,1) = classification(featuresInfo.featuresAll,obj.featureIndex{i,1}(j,:),obj.trainingRatio,obj.classifierFullTitle,obj.classificationRepetition);
                        y.accuracyBasicParameter{i,1}(j,1) = getBasicParameter(horzcat(obj.classificationOutput{i,1}(j,1).accuracyAll{:}));
                    end
                    y.accuracy{i,1} = vertcat(y.accuracyBasicParameter{i,1}.mean);
                    y.accuracyStde{i,1} = vertcat(y.accuracyBasicParameter{i,1}.stde);
                    [~,maxAccuracyLocs] = max(sum(y.accuracy{i,1},2));
                    y.accuracyMax(i,:) = y.accuracy{i,1}(maxAccuracyLocs,:);
                    y.maxFeatureCombo{i,1} = obj.featureIndex{i,1}(maxAccuracyLocs,:);
                end
                
                display(['Training session takes ',num2str(toc(tTrain)),' seconds...']);
            else
                y.classificationOutput = 0;
                y.featureIndex = 0;
                y.accuracyBasicParameter = 0;
            end
        end
        
        function resetImpl(obj)
            % Initialize discrete-state properties.
        end
    end
end
