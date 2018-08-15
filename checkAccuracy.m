% Obtain the highest acccuracy and the corresponding feature set

clear
close all

[files, path, iters] = selectFiles('select the desired classifier models');

% Parameters
maxNumFeatureUsed = 2;
numChannel = 2;
saveFigures = 1;

%% Load accuracies and feature IDs
fileSpeed = cell(0,0); % speeds contained in the file
fileDate = cell(0,0); % dates contained in the file
for i = 1:iters
    dataTemp = load(fullfile(path,files{1,i}));
    output(i,1) = getMaxAccuracy(dataTemp,maxNumFeatureUsed,numChannel);
    fileSpeed{i,1} = [files{1,i}(5:6),'_',files{1,i}(8),' vs ',files{1,i}(55:56),'_',files{1,i}(58)];
    fileDate{i,1} = files{1,i}(10:17);
end
        
%% separate accuracy and features ID according to their dimensions
% field: channel -> [iters, numFeatureUsed]
outputFieldNames = fieldnames(output);
numField = length(outputFieldNames);
for i = 1:numField
    outputIndividual.([outputFieldNames{i,1},'Individual']) = separateAccuracy(vertcat(output(:,1).(outputFieldNames{i,1})),numChannel,iters);
end

%% set xticklabel
for i = 1:iters
    for j = 1:numChannel
        featureIDStr{i,j} = checkMatNAddStr(outputIndividual.featureIDIndividual{j,1}(i,:), ',', 1);
    end
end

% for i = 1:numChannel
%     featureIDStr(:,i) = checkMatNAddStr(horzcat(fileDate,featureIDStr(:,i)),': ',1);
% end

%% Visualize
close all

xCoordinates = getErrorBarXAxisValues(iters,maxNumFeatureUsed); % for plotting mean and error bar
leftCoordinates = -1.8;

for i = 1:numChannel
    titleName = ['Highest accuracy of the days channel ', num2str(i)];
    saveName = [strrep(titleName,' ','_'),fileDate{1,1},'to',fileDate{end,1}];
    
    % plot the bar chart of accuracies
    p(i,1) = plotFig(1:iters,outputIndividual.accuracyMaxIndividual{i,1},'',titleName, '', 'Accuracy', 0, 1, path, 'overlap', 0, 'barGroupedPlot');
    ylim([0,1]);
    hold on
    
    % plot the mean
    meanTemp = outputIndividual.accuracyAveIndividual{i,1};
    plot(xCoordinates,meanTemp,'r*');
    
    % plot the percentile
    perc5Temp = meanTemp(:) - outputIndividual.accuracyPerc5Individual{i,1}(:);
    perc95Temp = outputIndividual.accuracyPerc95Individual{i,1}(:) - meanTemp(:);
    errorbar(xCoordinates(:),meanTemp(:),perc5Temp,perc95Temp,'kv');
    
    % change the XTickLabel
    p(i,1).XTick = 1:iters;
    p(i,1).XTickLabel = featureIDStr(:,i);

    % insert the number of used bursts
    text(leftCoordinates,0.98,'No. for training: ');
    text(1:iters,repmat(0.98,1,iters),checkMatNAddStr(outputIndividual.numTrainBurstIndividual{i,1},',',1));
    text(leftCoordinates,0.95,'No. for testing: ');
    text(1:iters,repmat(0.95,1,iters),checkMatNAddStr(outputIndividual.numTestBurstIndividual{i,1},',',1));
    
    % insert speed
    text(xCoordinates(:,1),repmat(0.05,1,iters),fileSpeed);
    
    % insert date
    text(xCoordinates(:,1),repmat(-0.07,1,iters),fileDate);
    
    % insert faeture legend
    legendMat = horzcat(mat2cell(transpose(1:8),ones(8,1),1),dataTemp.varargin{1,2}.featuresNames);
    legendText = checkMatNAddStr(legendMat,': ',1);
    t = text(leftCoordinates,0.1,legendText);
    
    % input bar legend
    barObj = vertcat(p(i,1).Children(end-2),p(i,1).Children(end-3),p(i,1).Children(end-4),p(i,1).Children(end-6));
    barObjLegend = [{'1-feature classification'};{'2-feature classification'};{'Mean value'};{'5 to 95 percentile'}];
    legend(barObj,barObjLegend,'Location','SouthEast')
    grid on
    
    if saveFigures
        savePlot(path,titleName,'',saveName);
    end
end

popMsg('Finished...');


