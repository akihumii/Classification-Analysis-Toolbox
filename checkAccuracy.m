% Obtain the highest acccuracy and the corresponding feature set

clear
close all

[files, path, iters] = selectFiles('select the desired classifier models');

% Parameters
maxNumFeatureUsed = 2;
numChannel = 2;
numClass = 2;
saveFigures = 0;

%% Load accuracies and feature IDs
fileSpeed = cell(0,0); % speeds contained in the file
fileDate = cell(0,0); % dates contained in the file
for i = 1:iters
    dataTemp = load(fullfile(path,files{1,i}));
    output(i,1) = getMaxAccuracy(dataTemp,maxNumFeatureUsed,numChannel,numClass);
    fileSpeed{i,1} = [files{1,i}(5:6),'_',files{1,i}(8),' vs ',files{1,i}(55:56),'_',files{1,i}(58)];
    fileDate{i,1} = files{1,i}(10:17);
end
fileSpeedOnly{1,1} = [fileSpeed{1,1}(1:2),'cm/s'];
fileSpeedOnly{2,1} = [fileSpeed{1,1}(9:10),'cm/s'];
    
        
%% separate accuracy and features ID according to their dimensions
% field: channel -> [iters, numFeatureUsed]
outputFieldNames = fieldnames(output);
outputFieldNames(end) = []; % this is the chosen accuracy locations
numField = length(outputFieldNames);
for i = 1:numField
    outputIndividual.([outputFieldNames{i,1},'Individual']) = separateAccuracy(vertcat(output(:,1).(outputFieldNames{i,1})),numChannel,iters);
end

%% set xticklabel
for i = 1:iters
    for j = 1:numChannel
        featureIDStr{i,j} = checkMatNAddStr(outputIndividual.featureIDIndividual{j,1}(i,:), ' | ', 1);
    end
end

% Rearrange sensitivity
outputIndividual.sensitivityMedianIndividual = rearrangeSensitivity(outputIndividual.sensitivityMedianIndividual);
outputIndividual.sensitivityAveIndividual = rearrangeSensitivity(outputIndividual.sensitivityAveIndividual);
outputIndividual.sensitivityPerc5Individual = rearrangeSensitivity(outputIndividual.sensitivityPerc5Individual);
outputIndividual.sensitivityPerc95Individual = rearrangeSensitivity(outputIndividual.sensitivityPerc95Individual);

%% Visualize
close all

xCoordinates = getErrorBarXAxisValues(iters,maxNumFeatureUsed); % for plotting mean and error bar
leftCoordinates = -1;

plotFeaturesBar('accuracy','medianPlot',numChannel,fileSpeed,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('maxValue','meanPlot',numChannel,fileSpeed,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('BL','meanPlot',numChannel,fileSpeed,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('meanValue','meanPlot',numChannel,fileSpeed,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

outputIndividualTemp = outputIndividual;

for i = 1:maxNumFeatureUsed
    outputIndividualTemp.sensitivityMedianIndividual = outputIndividual.sensitivityMedianIndividual(:,i);
    outputIndividualTemp.sensitivityAveIndividual = outputIndividual.sensitivityAveIndividual(:,i);
    outputIndividualTemp.sensitivityPerc5Individual = outputIndividual.sensitivityPerc5Individual(:,i);
    outputIndividualTemp.sensitivityPerc95Individual = outputIndividual.sensitivityPerc95Individual(:,i);
    
    pS{i,1} = plotFeaturesBar('sensitivity','medianPlot',numChannel,fileSpeed,fileDate,outputIndividualTemp,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,[num2str(i),'-feature classification channel'],featureIDStr);
    
end

popMsg('Finished...');


