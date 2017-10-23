function output = calculateAccuracy(prediction, testingClass, numClasses)
%calculateAccuracy Summary of this function goes here
%   Detailed explanation goes here

for i = 1:numClasses
    [element, locs] = find(testingClass == i);
    numTotal(i) = length(element);
    predictedTrue(i) = sum(prediction(locs) == testingClass(locs));
    predictedFalse(i) = numTotal(i) - predictedTrue(i);
    truePositive(i) = predictedTrue(i) / numTotal(i);
    falseNegative(i) = predictedFalse(i) / numTotal(i);
end

output.accuracy = sum(predictedTrue) / sum(numTotal);
output.truePositive = truePositive;
output.falseNegative = falseNegative;

end

