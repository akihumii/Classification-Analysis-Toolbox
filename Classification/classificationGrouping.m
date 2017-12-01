function grouping = classificationGrouping(features, trainingRatio, class, varargin)
%classificationGrouping Group the features into training and testing sets.
%Output grouping is in the structure of [windows * features * channels]
%   grouping = classificationGrouping(features, trainingRatio)
numChannels = size(features.(varargin{1}),2);
numFeatures = length(varargin);

training = cell(numChannels,1);
testing = cell(numChannels,1);
trainingClass = cell(numChannels,1);
testingClass = cell(numChannels,1);
all = cell(numChannels,1);

for i = 1:numChannels
    if numFeatures == 1 % to force the end result to be a 3d structure
        featureTemp = features.(varargin{1});
        validFeatures = featureTemp(~isnan(featureTemp(:,i)),i);
        numValidWindows = length(validFeatures);
        validFeatures = [validFeatures,nan(numValidWindows,1)];
    else
        for j = 1:numFeatures
            featureTemp = features.(varargin{j});
            validFeatures(:,j) = featureTemp(~isnan(featureTemp(:,i)),i);
        end
    end
    
    numWindows = size(validFeatures,1);
    numTrainingGroup = floor(numWindows * trainingRatio);
    randomSequence = randperm(numWindows);
    validFeatures = validFeatures(randomSequence,:); % neglect influence of sequential trend
    
    all{i,1} = validFeatures;
    training{i,1} = validFeatures(1:numTrainingGroup, :);
    testing{i,1} = validFeatures(numTrainingGroup+1:end, :);
    
    trainingClass{i,1} = [ones(numTrainingGroup,1) * class, nan(numTrainingGroup,1)];
    testingClass{i,1} = [ones(numWindows-numTrainingGroup,1) * class, nan(numWindows-numTrainingGroup,1)];
    
    clear validFeatures
end

if numFeatures == 1
    all = cell2nanMat(all);
    training = cell2nanMat(training);
    testing = cell2nanMat(testing);
    grouping.all = all(:,1,:);
    grouping.training = training(:,1,:);
    grouping.testing = testing(:,1,:);
else
    grouping.all = cell2nanMat(all);
    grouping.training = cell2nanMat(training);
    grouping.testing = cell2nanMat(testing);
end

trainingClass = cell2nanMat(trainingClass);
testingClass = cell2nanMat(testingClass);
grouping.trainingClass = trainingClass(:,1,:);
grouping.testingClass = testingClass(:,1,:);

end

