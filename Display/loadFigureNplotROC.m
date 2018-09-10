clear 
close all

data = cell(0,1);
titleName = cell(0,1);

%% load data
p = gca;
data = [data; p.Children.Data(~isnan(p.Children.Data))];
titleName = [titleName; p.Title.String];

%% get ready for ROC
numData = length(data);

% get the class flag
classFlag = zeros(0,1);

for i = 1:numData
    classFlag = [classFlag; i*ones(length(data{i,1}),1)];
end

% get the data
dataAll = vertcat(data{:,1});
dataAllMax = max(dataAll);
dataNormalize = dataAll/dataAllMax;

%% plot ROC
classFlagROC = mat2confusionMat(classFlag);
dataROC = [dataNormalize'; 1-dataNormalize'];

[tpr, fpr, th] = roc(classFlagROC, dataROC);

%% get the dot that is closest to the top left corner
% by getting the max distance from the corresponding middle line
numStep = length(tpr{1,1});
stepSize = 1/numStep;
middleLine = repmat(stepSize:stepSize:1,2,1);

for i = 1:numData
    tprLine{i,1} = [fpr{1,i}; tpr{1,i}];
    distance{i,1} = sum((middleLine - tprLine{i,1}) .^ 2);
    [~,maxDistanceLocs(i,1)] = max(distance{i,1});
end

%% Plot
figure
plotroc(classFlagROC, dataROC);
hold on

for i = 1:numData
    plot(fpr{1,i}(maxDistanceLocs(i,1)), tpr{1,i}(maxDistanceLocs(i,1)), 'ro');
end

%% result
for i = 1:numData
    thMax(i,1) = th{1,i}(maxDistanceLocs(i,1));
    thMax(i,1) = thMax(i,1) * dataAllMax;
end




