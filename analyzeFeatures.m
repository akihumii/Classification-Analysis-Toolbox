%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
% clc

%% User Input
runPCA = 1;
numPrinComp = 0; % number of principle component to use as features
threshPercentile = 50; % percentile to threshold the latent of principle component for data reconstruction
classificationRepetition = 1000; % number of repetition of the classification with randomly assigned training set and testing set
maxNumFeaturesInCombination = 2; % maximum nubmer of features used in combinations

% for display
displayInfo.testClassifier = 0;
displayInfo.saveOutput = 1;

displayInfo.showSeparatedFigures = 0;
displayInfo.showFigures = 0;
displayInfo.showHistFit = 0;
displayInfo.showAccuracy = 0;
displayInfo.showReconstruction = 1;
displayInfo.showPrinComp = 0;

displayInfo.saveSeparatedFigures = 0;
displayInfo.saveFigures = 0;
displayInfo.saveHistFit = 0;
displayInfo.saveAccuracy = 0;
displayInfo.saveReconstruction = 0;
displayInfo.savePrinComp = 0;

%% Get features info
[files, path, numClass] = selectFiles('select mat files for classifier''s training');

popMsg('Gathering features...');

%% Read and Reconstruct
for i = 1:numClass
    signalInfo(i,1) = getFeaturesInfo(path,files{1,i});
end

%% Reconstruct PCA
pcaInfo = reconstructPCA(signalInfo,threshPercentile); % matrix in [class x channel]

%% Reconstruct features in singal so that the structure is the same as the one in extracted Features.
featuresRaw = reconstructSignalInfoFeatures(signalInfo);

%% Run PCA
if runPCA
    %% Extract features from reconstructed signals after running PCA
    numChannel = length(signalInfo(1).signal.channel);
    for i = 1:numChannel
        featuresPCA(i,1) = featureExtraction(pcaInfo.pcaInfo(i,1).reconstructedData',1); % different channels stored in different structures. The structures mimics the one in signalInfo
        
        featuresPCA(i,1).burstLength = featuresRaw(i,1).burstLength(featuresRaw(i,1).burstLength ~= 0); % as the lengths have been trimmed, so this feature is no longer applicable and needs to be replaced with the original burst lengths
    end
    
    
    %% Reconstruct features
    % matrix of one feature = [bursts x class x features x channel]
    featuresInfo = reconstructFeatures(featuresPCA,numClass,pcaInfo.numBursts);
    
else    
    %% Reconstruct features
    % matrix of one feature = [bursts x class x features x channel]
    featuresInfo = reconstructFeatures(featuresRaw,numClass,pcaInfo.numBursts); % as the raw features still contains Nan, so number of bursts should not be trimmed too
    
    %% Adding PCA info as one feature
    if numPrinComp ~= 0
        featuresInfo = addPCAintoFeatures(featuresInfo,pcaInfo.scoreIndividual,numPrinComp);
    end
end

%% Train Classification
tTrain = tic;

classifierOutput = trainClassifier(featuresInfo, signalInfo, displayInfo, classificationRepetition, maxNumFeaturesInCombination);

display(['Training session takes ',num2str(toc(tTrain)),' seconds...']);

%% Plot features
tPlot = tic;
close all

% type can be 'Active EMG', 'Different Speed', 'Different Day'
visualizeFeatures(numClass, path, classifierOutput, featuresInfo, signalInfo, displayInfo, pcaInfo);

display(['Plotting session takes ',num2str(toc(tPlot)),' seconds...']);

%% Run through the entire signal and classify
if displayInfo.testClassifier
    tTest = tic;
    
    classificatioOutput = runClassifier(classifierOutput);
    
    display(['Continuous classification takes ',num2str(toc(tTrain)),' seconds...']);
end

%% Save the classification output and accuracy output
if displayInfo.saveOutput
    saveVar([path,'\classificationInfo\'],horzcat(signalInfo(:,1).saveFileName),classifierOutput,featuresInfo,signalInfo);
end

%% End
clear i j k

finishMsg()

