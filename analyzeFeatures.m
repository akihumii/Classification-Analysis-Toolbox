%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
clc

%% User Input
showSeparatedFigures = 0;
showFigures = 1;

saveSeparatedFigures = 0;
saveFigures = 0;

[files, path, iter] = selectFiles();

%% Get features info
for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    
    fileName{i,1} = signal(i,1).fileName;
    features(i,1) = signalClassification(i,1).features;
    fileSpeed{i,1} = fileName{i,1}(7:8);
    fileDate{i,1} = fileName{i,1}(12:17);
    
    dataFiltered{i,1} = signal(i,1).dataFiltered.values; 
    dataTKEO{i,1} = signal(i,1).dataTKEO.values; % signals for discrete classifcation
    samplingFreq(i,1) = signal(i,1).samplingFreq;
    detectionInfo{i,1} = signalClassification(i,1).burstDetection;
end

channel = signal(1,1).channel;
numChannel = length(channel);
featuresNames = fieldnames(features(1,1));
featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(featuresNames);

%% Reconstruct features
% matrix of one feature = [bursts x speeds x features x channel]
for i = 1:numFeatures
    for k = 1:numChannel
        for j = 1:iter % different speed
            featureNameTemp = featuresNames{i,1};
            featuresAll{j,i,k} = features(j,1).(featureNameTemp)(:,k); % it is sorted in [bursts * classes * features * channels]
            featureMean(i,j,k) = nanmean(featuresAll{j,i,k}); % it is sorted in [features * clases * channels]
            featureStd(i,j,k) = std(featuresAll{j,i,k}); % it is sorted in [features * classes * channels]
            featureStde(i,j,k) = featureStd(i,j,k) / sqrt(size(featuresAll{j,i,k},1)); % standard error of the feature
        end
    end
end

%% Run Classification
trainingRatio = 0.625;
featureIndex = [1];
classificationOutput = classification(featuresAll,featureIndex,trainingRatio);

linear = zeros(0,2);

for i = 1:length(classificationOutput.accuracy)
    accuracy(i,1) = classificationOutput.accuracy{1,i}.accuracy;
end

% %% Run SVM
% svmOuput = svmClassify(classificationOutput.grouping);

% %% Save file as .txt
% saveText(accuracy,const,linear,classificationOutput.channelPair, spikeTiming.threshold, windowSize);
% 

%% Run through the entire signal and classify
windowSize = 0.5; % window size in seconds
windowSkipSize = 0.05; % skipped window size in seconds
for i = 1:iter
    predictionOutput(i,1) = discreteClassification(dataTKEO{i,1},dataFiltered{i,1},samplingFreq(i,1),windowSize,windowSkipSize,detectionInfo{i,1},featureIndex,classificationOutput.coefficient,i);
end


%% Plot features
close all

% type can be 'Active EMG', 'Different Speed', 'Different Day'
visualizeFeatures(iter, path, channel, featureStde, 'Different Speed', fileName, fileSpeed, fileDate, numChannel, featureMean, featuresNames, numFeatures, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures);

clear i j k

finishMsg()


