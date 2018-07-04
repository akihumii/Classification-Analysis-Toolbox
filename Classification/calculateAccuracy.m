function output = calculateAccuracy(prediction, testingClass)
%calculateAccuracy Calculate the accuracy, truePositive, falseNegative.
%Prediction and testingClass should have the same size.
%
% output:   accuracy, truePositive, falseNegative
%
%   output = calculateAccuracy(prediction, testingClass)

classes = unique(testingClass);
numClasses = length(classes);

for i = 1:numClasses
    [locs, element] = find(testingClass == classes(i));
    numTotal(i,1) = length(element);
    predictedTrue(i,1) = sum(prediction(locs) == testingClass(locs));
    predictedFalse(i,1) = numTotal(i,1) - predictedTrue(i,1);
    truePositive(i,1) = predictedTrue(i,1) / numTotal(i,1);
    falseNegative(i,1) = predictedFalse(i,1) / numTotal(i,1);
end

try
    output.accuracy = sum(predictedTrue) / sum(numTotal);
    output.truePositive = truePositive;
    output.falseNegative = falseNegative;
catch
    output.accuracy = 0;
    output.truePositive = 0;
    output.falseNegative = 0;
end

end

