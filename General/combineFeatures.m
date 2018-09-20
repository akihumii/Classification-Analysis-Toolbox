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
    combinedFeatures.(featuresNames{i}) = squeezeNan(combinedFeatures.(featuresNames{i}),2);
end

%% Combine signalClassification
combinedSpikePeaksValue = zeros(0,1);
combinedSpikeLocs = zeros(0,1);
combinedBurstEndValue = zeros(0,1);
combinedEndLocs = zeros(0,1);
combinedNumBursts = zeros(size(signalClassification(1,1).selectedWindows.numBursts));
combinedGroupingAll = zeros(0,0,1);
combinedTraining = zeros(0,0,1);
combinedTesting = zeros(0,0,1);
combinedTrainingClass = zeros(0,0,1);
combinedTestingClass = zeros(0,0,1);

for i = 1:iter % different classes
    combinedBursts{i,1} = signalClassification(i,1).selectedWindows.burst; % different classes 
    combinedXAxisValues{i,1} = signalClassification(i,1).selectedWindows.xAxisValues;
    combinedNumBursts = combinedNumBursts + signalClassification(i,1).selectedWindows.numBursts;
    
    combinedSpikePeaksValue = [combinedSpikePeaksValue; signalClassification(i,1).burstDetection.spikePeaksValue];
    combinedSpikeLocs = [combinedSpikeLocs; signalClassification(i,1).burstDetection.spikeLocs];
    combinedBurstEndValue = [combinedBurstEndValue; signalClassification(i,1).burstDetection.burstEndValue];
    combinedEndLocs = [combinedEndLocs; signalClassification(i,1).burstDetection.burstEndLocs];
    
    combinedGroupingAll = [combinedGroupingAll; signalClassification(i,1).grouping.all];
    combinedTraining = [combinedTraining; signalClassification(i,1).grouping.training];
    combinedTesting = [combinedTesting; signalClassification(i,1).grouping.testing];
    combinedTrainingClass = [combinedTrainingClass; signalClassification(i,1).grouping.trainingClass];
    combinedTestingClass = [combinedTestingClass; signalClassification(i,1).grouping.testingClass];
end

% trim those variables
combinedBursts = catNanMat(combinedBursts,2,'all');
combinedBurstsMean = mean(combinedBursts,2);
combinedXAxisValues = catNanMat(combinedXAxisValues,2,'all');

combinedSpikePeaksValue = omitNan(combinedSpikePeaksValue,2,'all');
combinedSpikeLocs = omitNan(combinedSpikeLocs,2,'all');
combinedBurstEndValue = omitNan(combinedBurstEndValue,2,'all');
combinedEndLocs = omitNan(combinedEndLocs,2,'all');
combinedGroupingAll = omitNan(combinedGroupingAll,2,'all');
combinedTraining = omitNan(combinedTraining,2,'all');
combinedTesting = omitNan(combinedTesting,2,'all');
combinedTrainingClass = omitNan(combinedTrainingClass,2,'all');
combinedTestingClass = omitNan(combinedTestingClass,2,'all');

%% Combined windowsValues
numBurstsTemp = zeros(0,0);
burstMeanTemp = zeros(0,0);
for i = 1:iter
    burstTemp{i,1} = windowsValues(i,1).burst;
    xAxisValuesTemp{i,1} = windowsValues(i,1).xAxisValues;
    numBurstsTemp = [numBurstsTemp;windowsValues(i,1).numBursts']; % [class x channel]
end
combinedBurst = catNanMat(burstTemp,2,'all');
combinedBurstMean = nanmean(combinedBurst,2);
combinedXAxisValues2 = catNanMat(xAxisValuesTemp,2,'all');
combinedNumBursts = sum(numBurstsTemp,1);
    
%% Save it into one of the files, depending on saveFileIndex
clear windowsValues
if saveFile == 1
    combinedFeatures.dataAnalysed = signalClassification(1,1).features.dataAnalysed;
    signalClassification(1,1).features = combinedFeatures;
    signalClassification(1,1).selectedWindows.burst = combinedBursts;
    signalClassification(1,1).selectedWindows.burstMean = combinedBurstsMean;
    signalClassification(1,1).selectedWindows.xAxisValues = combinedXAxisValues;
    signalClassification(1,1).selectedWindows.numBursts = combinedNumBursts;
    signalClassification(1,1).burstDetection.spikePeaksValue = combinedSpikePeaksValue;
    signalClassification(1,1).burstDetection.spikeLocs = combinedSpikeLocs;
    signalClassification(1,1).burstDetection.burstEndValue = combinedBurstEndValue;
    signalClassification(1,1).burstDetection.burstEndLocs = combinedEndLocs;
    signalClassification(1,1).grouping.all = combinedGroupingAll;
    signalClassification(1,1).grouping.training = combinedTraining;
    signalClassification(1,1).grouping.testing = combinedTesting;
    signalClassification(1,1).grouping.trainingClass = combinedTrainingClass;
    signalClassification(1,1).grouping.testingClass = combinedTestingClass;
    windowsValues.burst = combinedBurst;
    windowsValues.burstMean = combinedBurstMean;
    windowsValues.xAxisValues = combinedXAxisValues2;
    windowsValues.numBursts = combinedNumBursts;
    
    saveVar(path,horzcat(signal(:,1).fileName),signal(1,1),signalClassification(1,1),windowsValues)
else
    warning('No file is saved because input ''saveFle'' is not 1')
end

finishMsg; % pop up a msg box to show FININSH :D

end

