function output = trainClassifier(featuresInfo, signalInfo, displayInfo, parameters)
%trainClassifier Train the classifier to use in analyzeFeatures
%
% output:   classificationOutput, accuracyBasicParameter, accuracy,
% accurcyStde, accuracyMax, maxFeatureCombo, classifierTitle,
% classifierFullTitle, featureIndex
%
%   output = trainClassifier(featuresInfo, signalInfo, displayInfo, parameters)

%% Parameters
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
    classNames{i,1} = char(fileType);
    classifierFullTitle = [classifierFullTitle,' ',classNames{i,1}];
end
classifierFullTitle = [classifierFullTitle,' )'];

%% Run Classification
if displayInfo.showHistFit||displayInfo.saveHistFit||displayInfo.showAccuracy||displayInfo.saveAccuracy||displayInfo.showReconstruction||displayInfo.saveReconstruction||displayInfo.showPrinComp||displayInfo.savePrinComp
    disp('Training classifiers...');
    
    lengthumFeaturesInCombination = length(parameters.numFeaturesInCombination);
    
    for i = 1:lengthumFeaturesInCombination
        featureIndex{i,1} = nchoosek(1:numFeatures,parameters.numFeaturesInCombination(i)); % n choose 
        
        try
            if all(parameters.featureIndexSelected{i,1} > 0)
                featureIndex{i,1} = featureIndex{i,1}(parameters.featureIndexSelected{i,1});
            end
        catch
        end
        
        numCombination = size(featureIndex{i,1},1); % number of combination
        for j = 1:numCombination
            classificationOutput{i,1}(j,1) = classification(featuresInfo.featuresAll,featureIndex{i,1}(j,:),signalInfo(i,1).signalClassification.trainingRatio,classifierFullTitle,parameters); % run the classification by using the features index etc
            accuracyBasicParameter{i,1}(j,1) = getBasicParameter(horzcat(classificationOutput{i,1}(j,1).accuracyAll)); % get the accuracy by checking the classification performances
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
output = makeStruct(...
    classificationOutput,...
    accuracyBasicParameter,...
    accuracy,...
    accuracyStde,...
    accuracyMax,...
    maxFeatureCombo,...
    classifierTitle,...
    classifierFullTitle,...
    featureIndex);

end
