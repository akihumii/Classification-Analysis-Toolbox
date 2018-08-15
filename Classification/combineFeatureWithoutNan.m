function output = combineFeatureWithoutNan(data,trainingRatio,numClasses)
%COMBINEFEATUREWITHOUTNAN Combine the features stored in structures while
%removing the Nan
% 
% input:    data: [class, feature]
%           trainingRatio: ratio of the whole set to use as training set
%           numClasses: number of set of different classes of data
% 
% output:   training, testing, trainingClass, testingClass
% 
%   output = combineFeatureWithoutNan(data,trainingRatio,numClasses)

training = zeros(0,1);
testing = zeros(0,1);
trainingClass = zeros(0,1);
testingClass = zeros(0,1);

for i = 1:numClasses
    
    trials = zeros(1,0);
    notNanFeatures = zeros(1,0);
    
    trials = catNanMat(data(i,:,1)',2,'all'); % concatanate the different classes into different columns including nan
    
    notNanFeatures = omitNan(trials,2,'any'); % get rid of rows containing Nan
    
    randFeatures = notNanFeatures(randperm(size(notNanFeatures,1)),:);
    numRandBursts = size(randFeatures,1); % number of bursts that are not nan
    trainingSet = randFeatures(1 : floor(trainingRatio * numRandBursts),:);
    testingSet = randFeatures(floor(trainingRatio * numRandBursts)+1 : end,:);
    training = [training; trainingSet];
    testing = [testing; testingSet];
    trainingClass = [trainingClass; i*ones(size(trainingSet,1),1)];
    testingClass = [testingClass; i*ones(size(testingSet,1),1)];
    
end

%% Output
output.training = training;
output.testing = testing;
output.trainingClass = trainingClass;
output.testingClass = testingClass;

end


