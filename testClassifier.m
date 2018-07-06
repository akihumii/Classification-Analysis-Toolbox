%% Run a trained classifier model on other data
%TESTCLASSIFIER

clear
% close all

% Select files of trained classifier model 
[files, path, iter] = selectFiles('Select the trained classifier model');
disp([fullfile(path,files{1,1}),' has been selected as trained classifier model...'])

% Load the required variables
fullInfo = load(fullfile(path,files{1,1}));
trainedClassifier = fullInfo.varargin{1,1};
threshPercentile = fullInfo.varargin{1,5}.threshPercentile;

% Run the prediction on target file
tTest = tic;
testClassifierOutput = runPrediction(trainedClassifier,threshPercentile);
disp(['Testing classification took ',num2str(toc(tTest)),' seconds...']);

% Visualize the accuracy
sizePrediction = size(testClassifierOutput.prediction); % [classifier dimensions x numChannel x week]
sizePrediction = [sizePrediction, length(testClassifierOutput.prediction{1,1,1})]; % [classifier dimensions x numChannel x week x classifier model]
predictionAll = vertcat(testClassifierOutput.prediction{:,:}); % line up all the output prediction
accuracy = vertcat(predictionAll.accuracy); % line up all the accuracy in a vertical array
accuracy = reshape(accuracy,sizePrediction);

accuracy = permute(accuracy,[1,3,2,4]); % change the dimensions into [classifier dimensions x week x channel]

% Get the legend name
legendName = cell(0,1);
for i = 1:size(accuracy,2)
    legendName = [legendName;{['Week ', num2str(i)]}];
end

for i = 1:size(accuracy,3) % plot different channels in different plots
    for j = 1:size(accuracy,4)
        p = plotFig(1:size(accuracy,1),accuracy(:,:,i,j),'',['Accuracy of classifier predicition on channel ',num2str(i), ' classifier model ',num2str(j)],'Classifier Models','Accuracy',0,1,path,'overlap',1,'barGroupedPlot'); % plot the figure
        numBars = length(p.Children);
        legend(p.Children(sqrt(numBars):-1:1),legendName)
        ylim([0,1])
        pause() % pause plotting the plots until user presses any key
    end
end

% Finish Message
finishMsg();
