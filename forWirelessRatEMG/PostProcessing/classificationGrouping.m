function grouping = classificationGrouping(features, trainingRatio)
%classificationGrouping Summary of this function goes here
%   Detailed explanation goes here

numTrial = length(features.classOne.maxValue);

numFeatures = length(features.classOne.maxValue);
numTrainingGroup = floor(numFeatures * trainingRatio);
randomSequence = randperm(numFeatures);

grouping.all.featureOne = [features.classOne.maxValue',features.classTwo.maxValue']; % row:windows ; column:class

grouping.training.featureOne = grouping.all.featureOne(randomSequence(1:numTrainingGroup),:); % row:windows ; column:class
grouping.training.reconstructed = [grouping.training.featureOne(:)]; % row:[windows of class1 ; window of class2]

grouping.testing.featureOne = grouping.all.featureOne(randomSequence(numTrainingGroup+1:end),:); % row:windows ; column:class
grouping.testing.reconstructed = [grouping.testing.featureOne(:)]; % row:[window of class1 ; window of class2] column:-

grouping.class = [zeros(numTrainingGroup,1);ones(numTrainingGroup,1)]; % row:[0,0,0,...,0,1,1,1,...]

end

