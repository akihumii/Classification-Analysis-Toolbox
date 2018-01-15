function output = calculateAccuracy(prediction, testingClass)
%calculateAccuracy Calculate the accuracy, truePositive, falseNegative.
%Prediction and testingClass should have the same size.
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

output.accuracy = sum(predictedTrue) / sum(numTotal);
output.truePositive = truePositive;
output.falseNegative = falseNegative;

end

