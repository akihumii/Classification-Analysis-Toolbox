function output = classification(trials,featureIndex,trainingRatio,classifierTitle)
%classification Perform lda classification with trials that are in cells
%   output = classification(trials,featureIndex)

[numClasses,~,numChannels] = size(trials);
numSelectedFeatures = length(featureIndex);

for i = 1:numChannels
    training{i,1} = zeros(0,1);
    testing{i,1} = zeros(0,1);
    trainingClass{i,1} = zeros(0,1);
    testingClass{i,1} = zeros(0,1);
    
    for j = 1:numClasses
        notNanFeaturesLocs = zeros(1,0);
        trialsTemp = zeros(1,0);
        notNanFeatures = zeros(1,0);
    
        for k = 1:numSelectedFeatures
            notNanFeaturesLocs = [notNanFeaturesLocs,~isnan(trials{j,featureIndex(1,k),i})]; % locations of the not nan values
            trialsTemp = [trialsTemp,trials{j,featureIndex(1,k),i}];
            notNanFeatures = trialsTemp(logical(notNanFeaturesLocs)); % get not nan values in a row
        end
        randFeatures = notNanFeatures(randperm(size(notNanFeatures,1)),:);
        numRandBursts = size(randFeatures,1); % number of bursts that are not nan
        trainingSet{i,j} = randFeatures(1 : floor(trainingRatio * numRandBursts),:);
        testingSet{i,j} = randFeatures(floor(trainingRatio * numRandBursts)+1 : end,:);
        training{i,1} = [training{i,1}; trainingSet{i,j}];
        testing{i,1} = [testing{i,1}; testingSet{i,j}];
        trainingClass{i,1} = [trainingClass{i,1}; j*ones(length(trainingSet{i,j}),1)];
        testingClass{i,1} = [testingClass{i,1}; j*ones(length(testingSet{i,j}),1)];
    end
    
    [class{i},error{i},posterior{i},logP{i},coefficient{i}] = ...
        classify(testing{i,1},training{i,1},trainingClass{i,1});
    
    accuracy{i} = calculateAccuracy(class{i},testingClass{i,1});
    
end

output.classifierTitle = classifierTitle;
output.class = class;
output.error = error;
output.posterior = posterior;
output.logP = logP;
output.coefficient = coefficient;
output.accuracy = accuracy;
output.trainingSet = trainingSet;
output.testingSet = testingSet;
output.training = training;
output.testing = testing;
output.trainingClass = trainingClass;
output.testingClass = testingClass;
end

