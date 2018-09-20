function [] = plot2ClassROC(data,dataClass,varargin)
%PLOT2CLASSROC Plot ROC to show the performance of 1-d classification by
%thresholding
% input:    data:       an 1-N array of data to be classified
%           dataClass:  an 1-N array of data class corresponding to data
% 
%   [] = plot2ClassROC(data,dataClass,varargin)

%% Parameters
data = checkSizeNTranspose(data,2);

parameters = struct(...
    'thresholdStepSize',(max(data)-min(data))/1e5,... % default step size for sweeping the threshold to classify two different class
    'saveROC',0,...
    'viewROC',1);

parameters = varIntoStruct(parameters,varargin);

%% Calculation
numClass = length(unique(dataClass));

currentThreshold = min(data);
% accuracyOutput = struct([]);

TPRAll = zeros(numClass,0);
FPRAll = zeros(numClass,0);

while currentThreshold <= max(data)
    accuracyOutput = calculateAccuracy(data < currentThreshold, dataClass);
%     accuracyOutput = [accuracyOutput; calculateAccuracy(data < currentThreshold, dataClass)];
    currentThreshold = currentThreshold + parameters.thresholdStepSize
    TPRAll = [TPRAll;accuracyOutput.TPR'];
    FPRAll = [FPRAll;accuracyOutput.FPR'];
end

%% Plotting
plotFig(TPRAll(:,1),FPRAll(:,1),'','ROC','TPR','FPR',parameters.saveROC,parameters.viewROC)
hold on
for i = 2:numClass
    plot(TPRAll(:,i),FPRAll(:,i));
end
end

