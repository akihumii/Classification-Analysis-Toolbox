%% main code for EMG analysis
% Include data filtering, peak detecting, windows overlapping, 
% figures displaying and saving.

clear
close all
clc

%% User's Input
% Parameters
dataType = 'neutrino'; % configurable types: 'neutirno', 'intan', 'sylphx', 'sylphii'
channel = [1,2]; % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
channelRef = 0; % input 0 if no differential data is needed.
samplingFreq = 3e6/14/3; % specified sampling frequency, otherwise input 0 for default value (Neutrino: 17500, intan: 30000, sylphX: 16671, sylphII: 16671)

dataToBeFiltered = 'dataRaw'; % input 'dataRaw' for raw data; input 'dataDelta' for differential data.
highPassCutoffFreq = 0; % high pass cutoff frequency, input 0 if not applied
lowPassCutoffFreq = 0; % low pass cutoff frequency, input 0 if not applied
notchFreq = 50; % notch frequency, input 0 if not applied

% Select window for overlapping. Spikes will be detected by thresholding
% with the value of 3/4 of the maximum value in the signal.
% Input 'dataRaw' for raw data, 'dataFiltered' for filtered data, 
% 'dataDelta' for differential data
selectedWindow = 'dataFiltered'; 
windowSize = [0.005, 0.02]; % size of selected window (in seconds)

% Show & Save Plots. Input 1 to save/show, otherwise input 0.
% Plots will be saved in the folder 'Figures' at the same path with the 
% processed data 
showRaw = 1;
showDelta = 0;
showFilt = 1;
showOverlap = 0;
saveRaw = 0;
saveDelta = 0;
saveFilt = 0;
saveOverlap = 0;

%% Main
ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis(dataType,dataToBeFiltered,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef,samplingFreq);
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

% clear

finishMsg = msgbox('Finished all prcoesses...');
pause(2)
delete(finishMsg)
display('Finished all processes...')


