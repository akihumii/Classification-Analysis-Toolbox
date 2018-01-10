%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
clc

%% User Input
showSeparatedFigures = 0;
showFigures = 1;

saveSeparatedFigures = 1;
saveFigures = 1;

[files, path, iter] = selectFiles();

%% Get features info
for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    
    fileName{i,1} = signal(i,1).fileName;
    features{i,1} = signalClassification(i,1).features;
    fileSpeed{i,1} = fileName{i,1}(7:8);
    fileDate{i,1} = fileName{i,1}(12:17);
end

channel = signal(1,1).channel;
numChannel = length(channel);
featuresNames = fieldnames(features{1,1});
featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(featuresNames);

%% Reconstruct features
% matrix of one feature = [bursts x speeds x features x channel]
for i = 1:numFeatures
    for j = 1:iter % different speed
        for k = 1:numChannel
            featureNameTemp = featuresNames{i,1};
            featuresAll(:,j,i,k) = features{j,1}.(featureNameTemp)(:,k);
            featureMean(i,j,k) = nanmean(featuresAll(:,j,i,k));
            featureStd(i,j,k) = std(featuresAll(:,j,i,k));
        end
    end
end

numBursts = size(featuresAll,1);

%% Run Classification
% classifier = runClassification('lda',signalClassification)

% classificationOutput = classification(features);
% 
% for i = 1:length(classificationOutput.accuracy)
%     accuracy(i,1) = classificationOutput.accuracy{1,i}.accuracy;
%     const(i,1) = classificationOutput.coefficient{1,i}(1,2).const;
%     linear(i,1) = classificationOutput.coefficient{1,i}(1,2).linear;
% end
% 
% %% Run SVM
% svmOuput = svmClassify(classificationOutput.grouping);
% 
% %% Save file as .txt
% saveText(accuracy,const,linear,classificationOutput.channelPair, spikeTiming.threshold, windowSize);


%% Plot features
close all

visualizeFeatures(iter, path, channel, featureStd, numBursts, 'Active EMG', fileName, fileSpeed, fileDate, numChannel, featureMean, featuresNames, numFeatures, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures);

clear i j k

finishMsg()


