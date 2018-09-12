%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures
function [] = analyzeFeatures(varargin)
% clear
close all
% clc

%% User Input
parameters = struct('useHPC',1,...
    ...
    'runPCA',0,...
    'numPrinComp',0,... % number of principle component to use as features
    'threshPercentile',95,... % percentile to threshold the latent of principle component for data reconstruction
    ...
    'classificationRepetition',5,...; % number of repetition of the classification with randomly assigned training set and testing set
    'numFeaturesInCominbation',1:2,... % array of nubmer of features used in combinations
    ...
    'classifierName','svm',...; % input only either 'lda' or 'svm'
    'classifierType',1,... % 1 for manually classification, 2 for using classifier learner app
    ...
    'trimBursts',1,...
    'balanceBursts',1); 

% for display
displayInfo = struct(...
    'testClassifier',0,...
    'saveOutput',1,...
    ...
    'showSeparatedFigures',0,...
    'showFigures',0,...
    'showHistFit',0,...
    'showAccuracy',1,...
    'showReconstruction',0,...
    'showPrinComp',0,...
    ...
    'saveSeparatedFigures',0,...
    'saveFigures',0,...
    'saveHistFit',0,...
    'saveAccuracy',0,...
    'saveReconstruction',0,...
    'savePrinComp',0);

% for additional amendment from varargin
parameters = varIntoStruct(parameters,varargin);
displayInfo = varIntoStruct(displayInfo,varargin);

%% Get features info
if parameters.useHPC
    allFiles = dir('*.mat');
    numTrial = length(allFiles);
    allPairs = nchoosek(1:numTrial,2);
    [numPairs, numClass] = size(allPairs);
else
    [files, path, numClass] = selectFiles('select mat files for classifier''s training');
    numPairs = 1;
end

for n = 1:numPairs
%     try
        if parameters.useHPC
            for j = 1:numClass
                files{1,j} = allFiles(allPairs(n,j),1).name;
            end
            path = [pwd,filesep];
        end
        
        disp('Gathering features...');
        
        %% Read and Reconstruct
        for i = 1:numClass
            signalInfo(i,1) = getFeaturesInfo(path,files{1,i});
        end
        
        %% Check burst intervals and then trim accordingly
        if parameters.trimBursts
            signalInfo = trimWithBurstIntervals(signalInfo,numClass,repmat([0,0.615; 0.615,3],1,1,2));
        end
        
        
        %% Balance the number of bursts from all the channels
        if parameters.balanceBursts
            signalInfo = balanceBursts(signalInfo,numClass);
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
                
                classifierOutput = trainClassifier(featuresInfo, signalInfo, displayInfo, parameters.classificationRepetition, parameters.numFeaturesInCominbation,parameters.classifierName);
                
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
                    disp(['Saving', saveDir, '...']);
                end
                
                %% End
                clear i j k
                
            case 2
                [channel1class1,channel1class2,channel2class1,channel2class2] = ...
                    loadDataForClassifyLearner(featuresInfo.featuresAll);
                
            otherwise
                warning('wrong classifier type... nothing was done...')
        end
%     catch
%         try
%             warning(['Error while training the pair ',checkMNAddStr(allPairs(i,:),'_')]);
%         catch
%             warning('Error while training the pair ...');
%         end
%     end
end
disp('Finish...')

end