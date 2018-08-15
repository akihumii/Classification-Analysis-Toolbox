% Obtain the highest acccuracy and the corresponding feature set

clear
close all

[files, path, iters] = selectFiles('select the desired classifier models');

% Parameters
maxNumFeatureUsed = 2;
numChannel = 2;

%% Load accuracies and feature IDs
for i = 1:iters
    dataTemp = load(fullfile(path,files{1,i}));
    [accuracyAll{i,1},featureIDAll{i,1},numTrainBurst{i,1},numTestBurst{i,1}] = getMaxAccuracy(dataTemp,maxNumFeatureUsed,numChannel);
    weekStr{i,1} = ['Week ',num2str(i)];
end
        
%% separate accuracy and features ID according to their dimensions
accuracyIndividual = separateAccuracy(accuracyAll,numChannel,iters);
featureIDIndividual = separateAccuracy(featureIDAll,numChannel,iters);
numTrainBurstIndividual = separateAccuracy(numTrainBurst,numChannel,iters);

%% set xticklabel
for i = 1:iters
    for j = 1:numChannel
        featureIDStr{i,j} = checkMatNAddStr(featureIDIndividual{j,1}(i,:), ' , ', 1);
    end
end

for i = 1:numChannel
    featureIDStr(:,i) = checkMatNAddStr(horzcat(weekStr,featureIDStr(:,i)),': ',1);
end

%% Visualize
for i = 1:numChannel
    % plot the bar chart of accuracies
    p(i,1) = plotFig(1:iters,accuracyIndividual{i,1},'',['Highest accuracy of the days channel ', num2str(i)], 'Week, Used Feature', 'Accuracy', 0, 1, path, 'overlap', 0, 'barGroupedPlot');
    ylim([0,1]);
    
    % change the XTickLabel
    p(i,1).XTick = 1:iters;
    p(i,1).XTickLabel = featureIDStr(:,i);

    % insert the number of used bursts
    text(0,-0.1,'Number of bursts in each class: ');
    text(1:iters,repmat(-0.1,1,iters),checkMatNAddStr(numTrainBurstIndividual{i,1},',',1));
    
    % insert faeture legend
    legendMat = horzcat(mat2cell(transpose(1:8),ones(8,1),1),dataTemp.varargin{1,2}.featuresNames);
    legendText = checkMatNAddStr(legendMat,': ',1);
    t = text(-0.3,0.9,legendText);
    
    grid on
end

popMsg('Finished...');


