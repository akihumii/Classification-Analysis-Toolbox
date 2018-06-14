%% Run a trained classifier model on other data
%TESTCLASSIFIER

clear
close all

% Select files of trained classifier model 
[files, path, iter] = selectFiles('Select the trained classifier model');

% Load the required variables
fullInfo = load(fullfile(path,files{1,1}));
trainedClassifier = fullInfo.varargin{1,1};
threshPercentile = fullInfo.varargin{1,5}.threshPercentile;

% Run the prediction on target file
tTest = tic;
testClassifierOutput = runPrediction(trainedClassifier,threshPercentile);
disp(['Testing classification takes ',num2str(toc(tTest)),' seconds...']);

% Visualize the accuracy
sizePrediction = size(testClassifierOutput.prediction); % [numFeatureSet x numChannel]
accuracy = vertcat(testClassifierOutput.prediction(:,:).accuracy); % line up all the accuracy in a vertical array
accuracy = reshape(accuracy,sizePrediction);

numFeatureSet = size(accuracy,1);
p = plotFig(1:numFeatureSet,accuracy,'','Accuracy of classifier models','Classifier Models','Accuracy',0,1,path,'overlap',1,'barGroupedPlot'); % plot the figure

% Get the legend name
legendName = cell(0,1);
for i = 1:numFeatureSet
    legendName = [legendName;{[num2str(i),' Dimension Classification']}];
end
numBars = length(p.Children);
legend(p.Children(numBars/2:-1:1),legendName)

