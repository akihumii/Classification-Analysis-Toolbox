function output = svmClassification(trainingGroup,trainingClassGroup,testingGroup)
%svmClassification Train the multi-class data with svm classifier by using error-correcting output codes.
% 
% output:   Mdl, CVMdl, oosLoss, predictClass
% 
%   output = svmClassification(trainingGroup,trainingClassGroup,testingGroup)

template = templateSVM('Standardize',1,'KernelFunction','gaussian');

Mdl = fitcecoc(trainingGroup,trainingClassGroup,'Learners',template,'FitPosterior',1,'Verbose',2);

CVMdl = crossval(Mdl); % kFold = 10 for cross-validation

oosLoss = kfoldLoss(CVMdl); % generalization error

%% Prediction
predictClass = predict(Mdl,testingGroup); % predict

% oofLabel = kfoldPredict(CVMdl); % predicted class, similar as the output of the function predict

%% Output
output.Mdl = Mdl;
output.CVMdl = CVMdl;
output.oosLoss = oosLoss;
output.predictClass = predictClass;

end

