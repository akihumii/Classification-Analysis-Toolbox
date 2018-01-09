%% Main code for Signal analysis
% Features data filtering, burst detecting, windows overlapping, 
% figures displaying and saving, bursts classification
% 
% Coded by Tsai Chne Wuen

clear
close all
clc

%% User's Input
% General Parameters
dataType = 'neutrino2'; % configurable types: ,'neutrino2','neutrino', 'intan', 'sylphx', 'sylphii'
channel = [1,2,3,4]; % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
channelPair = [1,2;3,2;4,2]; % input the pairs seperated in rows, eg:[1,2;3,4] means 1 pairs with 2 and 3 pairs with 4; input 0 if no differential data is needed.
samplingFreq = 0; % specified sampling frequency, otherwise input 0 for default value (Neutrino: 3e6/14/12, intan: 20000, sylphX: 1798.2, sylphII: 1798.2)
neutrinoInputReferred = 0; % input 1 to check input refer, otherwise input 0
neutrinoBit = 1; % input 1 for 8 bit mode, input 0 for 10 bit mode

partialDataSelection = 0; % input 1 to select partial data to analyse, otherwise input 0
constraintWindow = [0.776,4.6435]; % starting point and end point of constraint window, unit is in seconds. Input 0 for default (pre-select the whole signal). It can be found in signal.analysedDataTiming(2,:), the first row is the timing in seconds

% Filtering Parameters
dataToBeFiltered = 'dataDifferential'; % input 'dataRaw' for raw data; input 'dataDelta' for differential data; input 'dataRectified' for rectified data
highPassCutoffFreq = 30; % high pass cutoff frequency, input 0 if not applied
lowPassCutoffFreq = 500; % low pass cutoff frequency, input 0 if not applied
notchFreq = 50; % notch frequency, input 0 if not applied
decimateFactor = 1; % down sampling the data by a factor 'decimateFactor'

% FFT parameters
dataToBeFFT = 'dataDifferential'; % input 'dataRaw' for raw data; input 'dataFiltered' for filtered data; input 'dataRectified' for rectified data; input 'dataDifferential' for differential data

% Peak Detection Parameters
dataToBeDetectedSpike = 'dataDifferential'; % data for spike detecting
overlappedWindow = 'dataDifferential'; % Select window for overlapping. Input 'dataRaw' for raw data, 'dataFiltered' for filtered data, 'dataDifferential' for differential data
spikeDetectionType = 'local maxima'; % input 'local maxima' for local maxima, input 'trigger for first point exceeding threshold, input 'TKEO' for taking following consecutive points into account
threshold = [0]; % specified one threshold for spikes detection in all the channels; multiple thresholds are allowed for different channels; input 0 for default value (baseline + threshMult * baselineStandardDeviation) (baseline is obtained by calculating the mean of the data points spanned between 1/4 to 3/4 of the data array sorted by amplitudes)
threshStdMult = [0]; % multiples of standard deviation above the baseline as the threshold for TKEO detection. All channels will use the same value if there is only one value, multiple values are allowed for different channels
sign = 1; % input 1 for threhoslding upwards, input -1 for thresholding downwards
windowSize = [0.05, 0.3]; % range of window starting from the detected peaks(in seconds)
channelExtractStartingLocs = 0; % input channel index (start from 1, then 2, 3...) to fix the locs for all the channels, windows between 2 consecutive starting points of the bursts will be extracted and overlapped. Input 0 to deactivate this function
TKEOStartConsecutivePoints = 20; % number of consecutive points over the threshold to be detected as burst
TKEOEndConsecutivePoints = 500; % number of consecutive points below the threshold to be detected as end of burst


% Show & Save Plots Parameters. Input 1 to save/show, otherwise input 0.
% Plots will be saved in the folder 'Figures' at the same path with the processed data 
saveOption = 0;

showRaw = 1;
showDifferential = 1;
showRectified = 0;
showFilt = 0;
showOverlap = 1;
showFFT = saveOption;

saveRaw = 0;
saveDifferential = 0;
saveRectified = 0;
saveFilt = 0;
saveOverlap = saveOption;
saveFFT = saveOption;

saveUserInput = 0;

%% Main
ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis(dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelPair,samplingFreq,partialDataSelection,constraintWindow,neutrinoInputReferred,neutrinoBit,decimateFactor,saveOverlap,showOverlap,saveFFT,showFFT);
disp([num2str(toc(ticDataAnalysis)), ' seconds is used for loading and processing data...'])
disp(' ')

%% Locate bursts and select windows around them
tic
if showOverlap==1 || saveOverlap==1 % peaks detection is only activated when either showOverlap or saveOverlap or both of them are TRUE
    signalClassification = dataClassificationPreparation(signal, iter, overlappedWindow, windowSize,dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs);
else
    signalClassification = 1;
end
disp([num2str(toc),' seconds is used for classification preparation...'])
disp(' ')

%% Plot selected windows
close all

tic
visualizeSignals(signal, signalClassification, overlappedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT);
disp ([num2str(toc), ' seconds is used for visualizing signals...'])
disp(' ')

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

%% Ending
tic
if saveUserInput
    for i = 1:length(signal)
        saveVar(signal(i,1).path,signal(i,1).fileName,signal,signalClassification)
    end
end
disp ([num2str(toc), ' seconds is used for saving info...'])
disp(' ')

finishMsg()


