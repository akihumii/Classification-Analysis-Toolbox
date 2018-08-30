function output = calculateAccuracy(predictClass, trueClass)
%calculateAccuracy Calculate the accuracy, truePositive, falseNegative.
%Prediction and testingClass should have the same size.
% 
% output:   accuracy, truePositive, falseNegative
% 
%   output = calculateAccuracy(prediction, testingClass)

classes = unique(trueClass);
numObservation = length(trueClass);
numClasses = length(classes);

for i = 1:numClasses
    locs = trueClass == classes(i);
    TPplusFN(i,1) = sum(locs);
    TNplusFP(i,1) = sum(~locs);
    TP(i,1) = sum(predictClass(locs) == trueClass(locs));
    TN(i,1) = sum(predictClass(~locs) == trueClass(~locs));
    sensitivity(i,1) = TP(i,1) / TPplusFN(i,1);
    specificity(i,1) = TN(i,1) / TNplusFP(i,1);
    accuracy(i,1) = (TP(i,1)+TN(i,1)) / (TPplusFN(i,1)+TNplusFP(i,1));
end

output.accuracy = accuracy;
output.sensitivity = sensitivity;
output.specificity = specificity;

end

