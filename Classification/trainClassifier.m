function output = trainClassifier(featuresInfo, signalInfo, displayInfo, classificationRepetition, numFeaturesInCombination, classifierName)
%trainClassifier Train the classifier to use in analyzeFeatures
%
% output:   classificationOutput, accuracyBasicParameter, accuracy,
% accurcyStde, accuracyMax, maxFeatureCombo, classifierTitle,
% classifierFullTitle, featureIndex
%
%   output = trainClassifier(featuresInfo, signalInfo, displayInfo, classificationRepetition, maxNumFeaturesInCombination)

%% Parameters
trainingRatio = 0.7;
numFeatures = length(featuresInfo.featuresNames);
% featureIndex1D = 0; % input index number ([1,2,3,...]) of the features that are going to train in 1D classification, input 0 if want to train all features combinations
% featureIndex2D = 0; % input index number ([1,2,3,...]) of the features that are going to train in 2D classification, input 0 if want ot train all features combinations

%% Classification Settings
classifierTitle = 'Different Speed'; % it can be 'Different Speed','Different Day','Active EMG'
classifierFullTitle = [classifierTitle,' ('];
for i = 1:length(signalInfo)
    switch classifierTitle
        case 'Different Speed'
            fileType = signalInfo(i,1).fileSpeed;
        case 'Different Day'
            fileType = signalInfo(i,1).fileDate;
        case 'Active EMG'
            fileType = [{'Active'};{'Non Active'}];
    end
    classNames{i,1} = char(fileType);
    classifierFullTitle = [classifierFullTitle,' ',classNames{i,1}];
end
classifierFullTitle = [classifierFullTitle,' )'];

%% Run Classification
if displayInfo.showHistFit||displayInfo.saveHistFit||displayInfo.showAccuracy||displayInfo.saveAccuracy||displayInfo.showReconstruction||displayInfo.saveReconstruction||displayInfo.showPrinComp||displayInfo.savePrinComp
    disp('Training classifiers...');
    
    lengthumFeaturesInCombination = length(numFeaturesInCombination);
    
    for i = 1:lengthumFeaturesInCombination
        featureIndex{i,1} = nchoosek(1:numFeatures,numFeaturesInCombination(i)); % n choose 
        
%         if i == 2
%             if all(featureIndex2D > 0)
% %             selectedFeatureCombination = [2,12,22:30]; % select specific feature combinations to analyse
%             featureIndex{2,1} = featureIndex{2,1}(featureIndex2D,:);
%             end
%         else
%             if all(featureIndex1D > 0)
%             featureIndex{1,1} = featureIndex{1,1}(featureIndex1D,:);
%             end
%         end
        
        numCombination = size(featureIndex{i,1},1); % number of combination
        for j = 1:numCombination
            classificationOutput{i,1}(j,1) = classification(featuresInfo.featuresAll,featureIndex{i,1}(j,:),trainingRatio,classifierFullTitle,classificationRepetition,classifierName); % run the classification by using the features index etc
            accuracyBasicParameter{i,1}(j,1) = getBasicParameter(horzcat(classificationOutput{i,1}(j,1).accuracyAll(:))); % get the accuracy by checking the classification performances
        end
        accuracy{i,1} = vertcat(accuracyBasicParameter{i,1}.average);
        accuracyStde{i,1} = vertcat(accuracyBasicParameter{i,1}.standardDeviation);
        [~,maxAccuracyLocs] = max(sum(accuracy{i,1},2));
        accuracyMax(i,:) = accuracy{i,1}(maxAccuracyLocs,:);
        maxFeatureCombo{i,1} = featureIndex{i,1}(maxAccuracyLocs,:);
    end
    
else
    classificationOutput = 0;
    featureIndex = 0;
    accuracyBasicParameter = 0;
end

%% Output
output.classificationOutput = classificationOutput;
output.accuracyBasicParameter = accuracyBasicParameter;
output.accuracy = accuracy;
output.accuracyStde = accuracyStde;
output.accuracyMax = accuracyMax;
output.maxFeatureCombo = maxFeatureCombo;
output.classifierTitle = classifierTitle;
output.classifierFullTitle = classifierFullTitle;
output.featureIndex = featureIndex;

end
