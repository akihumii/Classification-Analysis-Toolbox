function output = calculateAccuracy(predictClass, trueClass)
%calculateAccuracy Calculate the accuracy, truePositive, falseNegative.
%Prediction and testingClass should have the same size.
% 
% output:   accuracy, sensitivity, specificity, TP, TN, FP, FN
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
    FN(i,1) = TPplusFN(i,1) - TP(i,1);
    FP(i,1) = TNplusFP(i,1) - TN(i,1);
    TPR(i,1) = sensitivity(i,1);
    FPR(i,1) = 1-specificity(i,1);
end

%% output
output = makeStruct(...
    accuracy,...
    sensitivity,...
    specificity,...
    TP,TN,FP,FN,TPR,FPR);

end

