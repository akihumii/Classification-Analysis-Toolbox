function output = trainClassifier(featuresInfo, signalInfo, displayInfo, classificationRepetition, maxNumFeaturesInCombination)
%trainClassifier Train the classifier to use in analyzeFeatures
%
% output:   classificationOutput, accuracyBasicParameter, accuracy,
% accurcyStde, accuracyMax, maxFeatureCombo, classifierTitle,
% classifierFullTitle, featureIndex
%
%   output = trainClassifier(featuresInfo, signalInfo, displayInfo, classificationRepetition, maxNumFeaturesInCombination)

%% Parameters
trainingRatio = 0.625;
numFeatures = length(featuresInfo.featuresNames);

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
    classifierFullTitle = [classifierFullTitle,' ',char(fileType)];
end
classifierFullTitle = [classifierFullTitle,' )'];

%% Run Classification
if displayInfo.showHistFit||displayInfo.saveHistFit||displayInfo.showAccuracy||displayInfo.saveAccuracy
    popMsg('Training classifiers...');
    
    for i = 1:maxNumFeaturesInCombination
        featureIndex{i,1} = nchoosek(1:numFeatures,i); % n choose k
        numCombination = size(featureIndex{i,1},1); % number of combination
        for j = 1:numCombination
            classificationOutput{i,1}(j,1) = classification(featuresInfo.featuresAll,featureIndex{i,1}(j,:),trainingRatio,classifierFullTitle,classificationRepetition); % run the classification by using the features index etc
            accuracyBasicParameter{i,1}(j,1) = getBasicParameter(horzcat(classificationOutput{i,1}(j,1).accuracyAll{:})); % get the accuracy by checking the classification performances
        end
        accuracy{i,1} = vertcat(accuracyBasicParameter{i,1}.mean);
        accuracyStde{i,1} = vertcat(accuracyBasicParameter{i,1}.stde);
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
