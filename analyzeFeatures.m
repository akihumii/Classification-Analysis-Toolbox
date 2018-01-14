%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
clc

%% User Input
testClassifier = 1;

showSeparatedFigures = 0;
showFigures = 1;

saveSeparatedFigures = 0;
saveFigures = 0;

%% Get features info
[files, path, iter] = selectFiles('select mat files for classifier''s training');

popMsg('Training clssifier...');

for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    
    fileName{i,1} = signal(i,1).fileName;
    features(i,1) = signalClassification(i,1).features;
    fileSpeed{i,1} = fileName{i,1}(7:8);
    fileDate{i,1} = fileName{i,1}(12:17);
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

%% Train Classification
trainingRatio = 0.625;
featureIndex = [1,2,5];

classifierTitle = 'Different Speed'; % it can be 'Different Speed','Different Day','Active EMG'
classifierFullTitle = [classifierTitle,' ('];
switch classifierTitle
    case 'Different Speed'
        fileType = fileSpeed;
    case 'Different Day'
        fileType = fileData;
    case 'Active EMG'
        fileType = [{'Active'};{'Non Active'}];
end
for i = 1:length(fileType)
    classifierFullTitle = [classifierFullTitle,' ',char(fileType{i,1})];
end
classifierFullTitle = [classifierFullTitle,' )'];

classificationOutput = classification(featuresAll,featureIndex,trainingRatio,classifierFullTitle,1000);

accuracy = classificationOutput.accuracy; % mean accuracy after all the repetitions

% %% Run SVM
% svmOuput = svmClassify(classificationOutput.grouping);

% %% Save file as .txt
% saveText(accuracy,const,linear,classificationOutput.channelPair, spikeTiming.threshold, windowSize);
% 

%% Plot features
close all

% type can be 'Active EMG', 'Different Speed', 'Different Day'
visualizeFeatures(iter, path, channel, featureStde, classifierTitle, fileName, fileSpeed, fileDate, numChannel, featureMean, featuresNames, numFeatures, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures);

%% Run through the entire signal and classify
if testClassifier
    
    windowSize = 0.5; % window size in seconds
    windowSkipSize = 0.05; % skipped window size in seconds
    
    [filesTest,pathTest,iterTest] = selectFiles('select mat files for continuous classifier''s testing');
    
    popMsg('Processing continuous classification...');

    correctClass = 1; % real class of the signal bursts
    
    for i = 1:iterTest % test the classifier
        infoTest(i,1) = load([pathTest,filesTest{i}]);
        signalTest(i,1) = infoTest(i,1).varargin{1,1};
        signalClassificationTest(i,1) = infoTest(i,1).varargin{1,2};
        fileNameTest{i,1} = signalTest(i,1).fileName;

        dataFilteredTest{i,1} = signalTest(i,1).dataFiltered.values;
        dataTKEOTest{i,1} = signalTest(i,1).dataTKEO.values; % signals for discrete classifcation
        samplingFreqTest(i,1) = signalTest(i,1).samplingFreq;
        detectionInfoTest{i,1} = signalClassificationTest(i,1).burstDetection;

        predictionOutput(i,1) = discreteClassification(dataTKEOTest{i,1},dataFilteredTest{i,1},samplingFreqTest(i,1),windowSize,windowSkipSize,detectionInfoTest{i,1},featureIndex,classificationOutput.coefficient,correctClass);
    end
    
    for i = 1:iterTest % visualize the classifier
        visualizeDetectedPoints(dataFilteredTest{i,1},predictionOutput(i,1).startPointAll,predictionOutput(i,1).endPointAll,samplingFreqTest(1,1),fileNameTest{i,1},pathTest);
    end
end

%% End
clear i j k

finishMsg()


