function [] = combineFeatures(saveFile)
%combineFeatures Combine features from two info files created by
%mainClassifier.m
% 
% input:    saveFile: input 1 to save the combined features with the remaining data in the first mat file, otherwise input 0;
% 
%   [combinedInfo] = combineFeatures(saveFileIndex)

%% Read files
[files,path,iter] = selectFiles('Select the mat files to combine their features');

for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    windowsValues(i,1) = info(i,1).varargin{1,3};
    features(i,1) = signalClassification(i,1).features;
end

%% Combine features
featuresNames = fieldnames(features(1,1));
featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(featuresNames);

for i = 1:numFeatures
    combinedFeatures.(featuresNames{i}) = vertcat(features(:).(featuresNames{i}));
end

%% Combine bursts and starting points and end points
combinedSpikeLocs = zeros(0,0);
combinedEndLocs = zeros(0,0);

for i = 1:iter % different classes
    combinedBursts{i,1} = signalClassification(i,1).selectedWindows.burst; % different classes 
    combinedSpikeLocs = [combinedSpikeLocs; signalClassification(i,1).burstDetection.spikeLocs];
    combinedEndLocs = [combinedEndLocs; signalClassification(i,1).burstDetection.burstEndLocs];
end

% trim those variables
combinedBursts = catNanMat(combinedBursts,2,'all');
combinedBurstsMean = mean(combinedBursts,2);

combinedSpikeLocs = omitNan(combinedSpikeLocs,2,'all');
combinedEndLocs = omitNan(combinedEndLocs,2,'all');

%% Combined sindowsValues
numBurstsTemp = zeros(0,0);
burstMeanTemp = zeros(0,0);
for i = 1:iter
    burstTemp{i,1} = windowsValues(i,1).burst;
    xAxisValuesTemp{i,1} = windowsValues(i,1).xAxisValues;
    numBurstsTemp = [numBurstsTemp;windowsValues(i,1).numBursts']; % [class x channel]
end
combinedBurst = catNanMat(burstTemp,2,'all');
combinedBurstMean = nanmean(combinedBurst,2);
combinedXAxisValues = catNanMat(xAxisValuesTemp,2,'all');
combinedNumBursts = sum(numBurstsTemp,1);
    
%% Save it into one of the files, depending on saveFileIndex
clear windowsValues
if saveFile == 1
    combinedFeatures.dataAnalysed = signalClassification(1,1).features.dataAnalysed;
    signalClassification(1,1).features = combinedFeatures;
    signalClassification(1,1).selectedWindows.burst = combinedBursts;
    signalClassification(1,1).selectedWindows.burstMean = combinedBurstsMean;
    signalClassification(1,1).burstDetection.spikeLocs = combinedSpikeLocs;
    signalClassification(1,1).burstDetection.burstEndLocs = combinedEndLocs;
    windowsValues.burst = combinedBurst;
    windowsValues.burstMean = combinedBurstMean;
    windowsValues.xAxisValues = combinedXAxisValues;
    windowsValues.numBursts = combinedNumBursts;
    saveVar(path,horzcat(signal(:,1).fileName),signal(1,1),signalClassification(1,1))
else
    warning('No file is saved because input ''saveFle'' is not 1')
end

finishMsg; % pop up a msg box to show FININSH :D

end

