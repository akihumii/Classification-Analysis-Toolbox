%% main code for EMG analysis
% including plotting figures, saving figures, selecting partial signals
% locating starting point and end point
% feature extraction
% classification

clear
close all
clc

%% User's Input
% Parameters
dataType = 'neutrino';
channel = [4,8,10]; % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
channelRef = 8; % input 0 if no differential data is needed. Raw data will be referred to differential data if this action is performed.

dataToBeFiltered = 'dataRaw'; % input 'dataRaw' for raw data; input 'dataDelta' for differential data.
highPassCutoffFreq = 5; % high pass cutoff frequency, input 0 if not applied
lowPassCutoffFreq = 500; % low pass cutoff frequency, input 0 if not applied
notchFreq = 50; % notch frequency, input 0 if not applied

% Select window for overlapping. Input 'dataRaw' for raw data and
% 'dataFiltered' for filtered data, input 'dataDelta' for differential data
selectedWindow = 'dataDelta'; 
windowSize = [0.005, 0.02]; % size of selected window (in seconds)

% Show & Save Plots. Input 1 to save/show, otherwise input 0.
showRaw = 1;
showDelta = 1;
showFilt = 1;
showOverlap = 1;
saveRaw = 0;
saveDelta = 0;
saveFilt = 0;
saveOverlap = 0;

%% Main
ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis(dataType,dataToBeFiltered,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef);
signal
disp([num2str(toc(ticDataAnalysis)), ' seconds used for loading and processing data...'])

%% Locate bursts and select windows around them
tic
signalClassification = dataClassificationPreparation(signal, iter, selectedWindow, windowSize)
disp([num2str(toc),' seconds used for classification preparation...'])

%% Plot selected windows
close all

tic
visualizeSignals(signal, signalClassification, selectedWindow, saveRaw, showRaw, saveDelta, showDelta, saveFilt, showFilt, saveOverlap, showOverlap);
disp ([num2str(toc), ' seconds used for visualizing signals...'])

%% Run Classification
classifier = runClassification('lda',signalClassification)

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

% clear

finishMsg = msgbox('Finished all prcoesses...');
pause(2)
delete(finishMsg)
display('Finished all processes...')


