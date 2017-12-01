function output = classification(features)
%classification Summary of this function goes here
%   Detailed explanation goes here

numRepetition = 1;
trainingRatio = 0.625;

grouping = classificationGrouping(features,trainingRatio);

for i = 1:numRepetition
    
    [class{i},error{i},posterior{i},logP{i},coefficient{i}] = ...
        classify(grouping.testing.reconstructed,grouping.training.reconstructed,grouping.class);
    
end

output.class = class;
output.error = error;
output.posterior = posterior;
output.logP = logP;
output.coefficient = coefficient;

end

