function output = classification(trials,featureIndex,trainingRatio)
%classification Perform lda classification with trials that are in cells
%   output = classification(trials,featureIndex)

[numBursts,numClasses,~,numChannels] = size(trials);

for i = 1:numChannels
    training{i,1} = zeros(0,1);
    testing{i,1} = zeros(0,1);
    trainingClass{i,1} = zeros(0,1);
    testingClass{i,1} = zeros(0,1);
    
    for j = 1:numClasses
        notNanFeaturesLocs = ~isnan(trials(:,j,featureIndex,i)); % locations of the not nan values
        trialsTemp = trials(:,j,featureIndex,i);
        notNanFeatures = trialsTemp(notNanFeaturesLocs); % get not nan values in a row
        notNanFeatures = reshape(notNanFeatures,length(notNanFeatures)/2,[]);
        randFeatures = notNanFeatures(randperm(size(notNanFeatures,1)),:);
        trainingSet{i,j} = randFeatures(1 : floor(trainingRatio * numBursts),j);
        testingSet{i,j} = randFeatures(floor(trainingRatio * numBursts)+1 : end,j);
        training{i,1} = [training{i,1}; trainingSet{i,j}];
        testing{i,1} = [testing{i,1}; testingSet{i,j}];
        trainingClass{i,1} = [trainingClass{i,1}; j*ones(length(trainingSet{i,j}),1)];
        testingClass{i,1} = [testingClass{i,1}; j*ones(length(testingSet{i,j}),1)];
    end
    
    

    
    [class{i},error{i},posterior{i},logP{i},coefficient{i}] = ...
        classify(testing{i,1},training{i,1},trainingClass{i,1});
    
    accuracy{i} = calculateAccuracy(class{i},testingClass{i,1},numClasses);
    
end

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

