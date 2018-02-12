%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
% clc

%% User Input
displayInfo.testClassifier = 0;
displayInfo.saveOutput = 1;

displayInfo.showSeparatedFigures = 0;
displayInfo.showFigures = 0;
displayInfo.showHistFit = 1;
displayInfo.showAccuracy = 1;

displayInfo.saveSeparatedFigures = 0;
displayInfo.saveFigures = 0;
displayInfo.saveHistFit = 0;
displayInfo.saveAccuracy = 0;

%% Get features info
[files, path, iter] = selectFiles('select mat files for classifier''s training');

popMsg('Gathering features...');

%% Read and Reconstruct 
for i = 1:iter
    signalInfo(i,1) = getFeaturesInfo(path,files{1,i});    
end

%% Reconstruct features
% matrix of one feature = [bursts x speeds x features x channel]
featuresInfo = reconstructFeatures(signalInfo,iter);

%% Reconstruct PCA
pcaInfo = reconstructPCA(signalInfo,iter);

%% Adding PCA info as one feature
featureInfo = addPCAintoFeatures(featuresInfo,pcaInfo.pcUsageLocs);

%% Train Classification
tTrain = tic;

classifierOutput = trainClassifier(featuresInfo, signalInfo, displayInfo);

%% Plot features
tPlot = tic;
close all

% type can be 'Active EMG', 'Different Speed', 'Different Day'
visualizeFeatures(iter, path, channel, classificationOutput, featureIndex, accuracyBasicParameter, featuresInfo, classifierTitle, fileName, signalInfo, displayInfo);

display(['Plotting session takes ',num2str(toc(tTrain)),' seconds...']);

%% Run through the entire signal and classify
if displayInfo.testClassifier
    tTest = tic;

    classificatioOutput = runClassifier(classifierOutput);

    display(['Continuous classification takes ',num2str(toc(tTrain)),' seconds...']);
end

%% Save the classification output and accuracy output
if displayInfo.saveOutput
    saveVar([path,'\classificationInfo\'],horzcat(signalInfo(:,1).saveFileName),classificationOutput,accuracyBasicParameter);
end

%% End
clear i j k

finishMsg()

