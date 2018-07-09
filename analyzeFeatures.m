%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures
function [] = analyzeFeatures()
clear
close all
% clc

%% User Input
parameters.runPCA = 0;
parameters.numPrinComp = 0; % number of principle component to use as features
parameters.threshPercentile = 95; % percentile to threshold the latent of principle component for data reconstruction
parameters.classificationRepetition = 1000; % number of repetition of the classification with randomly assigned training set and testing set
parameters.maxNumFeaturesInCominbation = 2; % maximum nubmer of features used in combinations

parameters.classifierName = 'svm'; % input only either 'lda' or 'svm'
parameters.classifierType = 1; % 1 for manually classification, 2 for using classifier learner app

% for display
displayInfo.testClassifier = 0;
displayInfo.saveOutput = 1;

displayInfo.showSeparatedFigures = 0;
displayInfo.showFigures = 0;
displayInfo.showHistFit = 0;
displayInfo.showAccuracy = 1;
displayInfo.showReconstruction = 0;
displayInfo.showPrinComp = 0;

displayInfo.saveSeparatedFigures = 0;
displayInfo.saveFigures = 0;
displayInfo.saveHistFit = 0;
displayInfo.saveAccuracy = 0;
displayInfo.saveReconstruction = 0;
displayInfo.savePrinComp = 0;

%% Get features info
% [files, path, numClass] = selectFiles('select mat files for classifier''s training');
allFiles = dir('*.mat');
numTrial = length(allFiles);
allPairs = nchoosek(1:numTrial,2);
[numPairs, numClass] = size(allPairs);
for i = 1:numPairs
    for j = 1:numClass
        files{1,j} = allFiles(allPairs(i,j),1).name;
    end
    path = [pwd,filesep];
    
    disp('Gathering features...');
    
    %% Read and Reconstruct
    for i = 1:numClass
        signalInfo(i,1) = getFeaturesInfo(path,files{1,i});
    end
    
    %% Reconstruct PCA
    pcaInfo = reconstructPCA(signalInfo,parameters.threshPercentile); % matrix in [class x channel]
    
    %% Reconstruct features in singal so that the structure is the same as the one in extracted Features.
    featuresRaw = reconstructSignalInfoFeatures(signalInfo);
    
    %% Run PCA
    if parameters.runPCA
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
    end
    
    %% Adding PCA info as one feature
    if parameters.numPrinComp ~= 0
        featuresInfo = addPCAintoFeatures(featuresInfo,pcaInfo.scoreIndividual,parameters.numPrinComp);
    end
    
    switch parameters.classifierType
        case 1
            %% Train Classification
            tTrain = tic;
            
            classifierOutput = trainClassifier(featuresInfo, signalInfo, displayInfo, parameters.classificationRepetition, parameters.maxNumFeaturesInCominbation,parameters.classifierName);
            
            display(['Training session takes ',num2str(toc(tTrain)),' seconds...']);
            
            %% Plot features
            %         tPlot = tic;
            %         close all
            %
            %         % type can be 'Active EMG', 'Different Speed', 'Different Day'
            %         visualizeFeatures(numClass, path, classifierOutput, featuresInfo, signalInfo, displayInfo, pcaInfo, parameters.runPCA);
            %
            %         display(['Plotting session takes ',num2str(toc(tPlot)),' seconds...']);
            
            %% Run through the entire signal and classify
            if displayInfo.testClassifier
                tTest = tic;
                
                testClassifierOutput = runPrediction(classifierOutput,parameters.threshPercentile);
                
                display(['Testing classification takes ',num2str(toc(tTest)),' seconds...']);
            end
            
            %% Save the classification output and accuracy output
            if displayInfo.saveOutput
                saveDir = saveVar(fullfile(path,'classificationInfo'),horzcat(signalInfo(:,1).saveFileName),classifierOutput,featuresInfo,signalInfo,pcaInfo,parameters);
                disp(saveDir);
            end
            
            %% End
            clear i j k
            
        case 2
            [channel1class1,channel1class2,channel2class1,channel2class2] = ...
                loadDataForClassifyLearner(featuresInfo.featuresAll);
            
        otherwise
            warning('wrong classifier type... nothing was done...')
    end
end
disp('Finish...')

end