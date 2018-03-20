function [] = svmClassification(trainingGroup,trainingClassGroup,testingGroup,classNames)
%svmClassification Train the multi-class data with svm classifier by using error-correcting output codes.
% 
%   Detailed explanation goes here

template = templateSVM('Standardize',1,'KernelFunction','gaussian');

Mdl = fitcecoc(trainingGroup,trainingClassGroup,'Learners',template,'FitPosterior',1,'Verbose',2);

CVMdl = crossval(Mdl); % kFold = 10 for cross-validation

oosLoss = kfoldLoss(CVMdl); % generalization error

%% visualization
xMax = max(trainingGroup);
xMin = min(trainingGroup);

x1Pts = linspace(xMin(1),xMax(1));
x2Pts = linspace(xMin(2),xMax(2));
[x1Grid,x2Grid] = meshgrid(x1Pts,x2Pts);

[~,~,~,PosteriorRegion] = predict(Mdl,[x1Grid(:),x2Grid(:)]);

figure
contourf(x1Grid,x2Grid,...
    reshape(max(PosteriorRegion,[],2),size(x1Grid,1),size(x1Grid),2));
h = colorbar;
h.YLabel.String = 'Maximum posterior';
h.Ylabel.Fontsize = 15;
hold on
gh = gscatter(X(:,1),X(:,2),trainingClassGroup,'krk','*xd',8);
gh(2).LineWidth = 2;
gh(3).LineWidth = 2;

axis tight
legend(gh)
end

