% Obtain the highest acccuracy and the corresponding feature set

function [] = checkAccuracy(varargin)
% Parameters
parameters = struct(...
    'selectFile',1,...
    'maxNumFeatureUsed',2,...
    'numChannel',2,...
    'numClass',2,...
    'lowerPercThresh',25,...
    'upperPercThresh',75,...
    'saveFigures',1);

parameters = varIntoStruct(parameters,varargin);

if parameters.selectFile
    [files, path, iters] = selectFiles('select the desired classifier models');
else
    [files, path, iters] = getCurrentFiles('*.mat');
end

%% Load accuracies and feature IDs
fileSpeed = cell(0,0); % speeds contained in the file
fileDate = cell(0,0); % dates contained in the file
for i = 1:iters
    dataTemp = load(fullfile(path,files{1,i}));
    output(i,1) = getMaxAccuracy(dataTemp,parameters);
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
    outputIndividual.([outputFieldNames{i,1},'Individual']) = separateAccuracy(vertcat(output(:,1).(outputFieldNames{i,1})),parameters.numChannel,iters);
end

%% set xticklabel
for i = 1:iters
    for j = 1:parameters.numChannel
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

xCoordinatesErrorbarAccuracy = getErrorBarXAxisValues(iters,parameters.maxNumFeatureUsed); % for plotting mean and error bar for accuracy
xCoordinatesErrorbarSensitivity = getErrorBarXAxisValues(iters,parameters.numChannel); % for plotting mean and error bar for accuracy
xCoordinatesNumClass = getErrorBarXAxisValues(iters,parameters.numClass);
leftCoordinates = -1;

plotFeaturesBar('accuracy','medianPlot',parameters,path,fileSpeed,fileDate,outputIndividual,xCoordinatesErrorbarAccuracy,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('maxValue','meanPlot',parameters,path,fileSpeed,fileDate,outputIndividual,xCoordinatesNumClass,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('BL','meanPlot',parameters,path,fileSpeed,fileDate,outputIndividual,xCoordinatesNumClass,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

plotFeaturesBar('meanValue','meanPlot',parameters,path,fileSpeed,fileDate,outputIndividual,xCoordinatesNumClass,iters,leftCoordinates,fileSpeedOnly,dataTemp,'channel',featureIDStr);

outputIndividualTemp = outputIndividual;

for i = 1:parameters.maxNumFeatureUsed
    outputIndividualTemp.sensitivityMedianIndividual = outputIndividual.sensitivityMedianIndividual(:,i);
    outputIndividualTemp.sensitivityAveIndividual = outputIndividual.sensitivityAveIndividual(:,i);
    outputIndividualTemp.sensitivityPerc5Individual = outputIndividual.sensitivityPerc5Individual(:,i);
    outputIndividualTemp.sensitivityPerc95Individual = outputIndividual.sensitivityPerc95Individual(:,i);
    
    pS{i,1} = plotFeaturesBar('sensitivity','medianPlot',parameters,path,fileSpeed,fileDate,outputIndividualTemp,xCoordinatesErrorbarSensitivity,iters,leftCoordinates,fileSpeedOnly,dataTemp,[num2str(i),'-feature classification channel'],featureIDStr);
end

popMsg('Finished...');

end
