function output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat)
%classification Perform lda classification with trials that are in cells
%   output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat)

[numClasses,~,numChannels] = size(trials);
numSelectedFeatures = length(featureIndex);

for i = 1:numChannels
    accuracyHighest(1,i) = 0; % initialize accuracy
    accuracyAll{i,1} = zeros(0,1); % store all the accuracy in this array
    
    for r = 1:numRepeat
        trainingTemp = zeros(0,1);
        testingTemp = zeros(0,1);
        trainingClassTemp = zeros(0,1);
        testingClassTemp = zeros(0,1);
        
        for j = 1:numClasses
            notNanFeaturesLocs = zeros(1,0);
            trialsTemp = zeros(1,0);
            notNanFeatures = zeros(1,0);
            
            for k = 1:numSelectedFeatures % concatanate the different classes into different columns
                notNanFeaturesLocs = [notNanFeaturesLocs,~isnan(trials{j,featureIndex(1,k),i})]; % locations of the not nan values
                trialsTemp = [trialsTemp,trials{j,featureIndex(1,k),i}];
                notNanFeatures = [notNanFeatures,trialsTemp(logical(notNanFeaturesLocs(:,k)),k)]; % get not nan values in a row
            end
            randFeatures = notNanFeatures(randperm(size(notNanFeatures,1)),:);
            numRandBursts = size(randFeatures,1); % number of bursts that are not nan
            trainingSetTemp = randFeatures(1 : floor(trainingRatio * numRandBursts),:);
            testingSetTemp = randFeatures(floor(trainingRatio * numRandBursts)+1 : end,:);
            trainingTemp = [trainingTemp; trainingSetTemp];
            testingTemp = [testingTemp; testingSetTemp];
            trainingClassTemp = [trainingClassTemp; j*ones(length(trainingSetTemp),1)];
            testingClassTemp = [testingClassTemp; j*ones(length(testingSetTemp),1)];
        end
        
        [classTemp,errorTemp,posteriorTemp,logPTemp,coefficientTemp] = ...
            classify(testingTemp,trainingTemp,trainingClassTemp);
        
        accuracyTemp = calculateAccuracy(classTemp,testingClassTemp);
        
        accuracyAll{i,1} = [accuracyAll{i,1};accuracyTemp.accuracy];
        
        if accuracyTemp.accuracy > accuracyHighest(1,i) % record the result from the classifier that has the highest performance
            accuracyHighest(1,i) = accuracyTemp.accuracy;
            class{i,1} = classTemp;
            error{i,1} = errorTemp;
            posterior{i,1} = posteriorTemp;
            logP{i,1} = logPTemp;
            coefficient{i,1} = coefficientTemp;
            trainingSet{i,1} = trainingSetTemp;
            testingSet{i,1} = testingSetTemp;
            training{i,1} = trainingTemp;
            testing{i,1} = testingTemp;
            trainingClass{i,1} = trainingClassTemp;
            testingClass{i,1} = testingClassTemp;
        end
    end
    accuracy(1,i) = mean(accuracyAll{i,1});
end

output.classifierTitle = classifierTitle;
output.class = class;
output.error = error;
output.posterior = posterior;
output.logP = logP;
output.coefficient = coefficient;
output.accuracy = accuracy; % a matrix of numbers which are the mean accuracy after all the repeatations
output.accuracyAll = accuracyAll;
output.accuracyHighest = accuracyHighest; % a structure containing accuracy, true positive and false negative
output.trainingSet = trainingSet;
output.testingSet = testingSet;
output.training = training;
output.testing = testing;
output.trainingClass = trainingClass;
output.testingClass = testingClass;
end

