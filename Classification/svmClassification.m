function [] = svmClassification(trainingGroup,trainingClassGroup,testingGroup,classNames)
%svmClassification Train the multi-class data with svm classifier by using error-correcting output codes.
% 
%   Detailed explanation goes here

template = templateSVM('Standardize',1,'KernelFunction','gaussian');

Mdl = fitcecoc(trainingGroup,trainingClassGroup,'Learners',template,'FitPosterior',1,'Verbose',2);

CVMdl = crossval(Mdl); % kFold = 10 for cross-validation

oosLoss = kfoldLoss(CVMdl); % generalization error

%% Prediction
predictClass = predict(Mdl,trainingGroup); % predict
oofLabel = kfoldPredict(CVMdl); % predicted class, similar as the output of the function predict
isLabels = unique(trainingClassGroup);
nLabels = numel(isLabels);
[n,p] = size(trainingGroup);

% Convert the integer label vector to a class-identifier matrix.
[~,grpOOF] = ismember(oofLabel,isLabels); 
oofLabelMat = zeros(nLabels,n); 
idxLinear = sub2ind([nLabels n],grpOOF,(1:n)'); 
oofLabelMat(idxLinear) = 1; % Flags the row corresponding to the class 
[~,grpY] = ismember(trainingClassGroup,isLabels); 
YMat = zeros(nLabels,n); 
idxLinearY = sub2ind([nLabels n],grpY,(1:n)'); 
YMat(idxLinearY) = 1; 

figure;
plotconfusion(YMat,oofLabelMat);
h = gca;
h.XTickLabel = [num2cell(isLabels); {''}];
h.YTickLabel = [num2cell(isLabels); {''}];

% [~,~,~,PosteriorRegion] = predict(Mdl,trainingGroup);

end

