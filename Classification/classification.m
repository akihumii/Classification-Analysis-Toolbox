function output = classification(trials)
%classification Perform lda classification
%   output = classification(grouping)

numClasses = length(trials);
numChannels = size(trials(1).grouping.training,3);

for i = 1:numChannels
    training = zeros(0,0);
    testing = zeros(0,0);
    trainingClass = zeros(0,0);
    testingClass = zeros(0,0);
    
    for j = 1:numClasses
        training = [training; trials(j).grouping.training(:,:,i)];
        testing = [testing; trials(j).grouping.testing(:,:,i)];
        trainingClass = [trainingClass; trials(j).grouping.trainingClass(:,:,i)];
        testingClass = [testingClass; trials(j).grouping.testingClass(:,:,i)];
    end
    
    [class{i},error{i},posterior{i},logP{i},coefficient{i}] = ...
        classify(testing,training,trainingClass);
    
    accuracy{i} = calculateAccuracy(class{i},testingClass,numClasses);
    
    clear training testing trainingClass testingClass
end

output.class = class;
output.error = error;
output.posterior = posterior;
output.logP = logP;
output.coefficient = coefficient;
output.accuracy = accuracy;
end

