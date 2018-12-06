%% Main code for Signal analysis
% Features data filtering, burst detecting, windows overlapping, 
% figures displaying and saving, bursts classification
% 
% Coded by Tsai Chne Wuen

clear
close all
% clc

%% User's Input
% General Parameters
dataType = 'odin'; % configurable types: ,'neutrino2','neutrino', 'intan', 'sylphx', 'sylphii'
channel = [4,13,14,15]; % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
channelPair = [0]; % input the pairs seperated in rows, eg:[1,2;3,4] means 1 pairs with 2 and 3 pairs with 4; input 0 if no differential data is needed.
samplingFreq = 0; % specified sampling frequency, otherwise input 0 for default value (Neutrino: 3e6/14/12, intan: 20000, sylphX: 1798.2, sylphII: 1798.2)
neutrinoInputReferred = 0; % input 1 to check input refer, otherwise input 0
neutrinoBit = 1; % input 1 for 8 bit mode, input 0 for 10 bit mode
partialDataSelection = 0; % input 1 to select partial data to analyse, otherwise input 0
constraintWindow = [-0.300750000000000,6.90490000000000]; % starting point and end point of constraint window, unit is in seconds. Input 0 for default (pre-select the whole signal). It can be found in signal.analysedDataTiming(2,:), the first row is the timing in seconds

% Odin Parameters
odinparam = struct(...
    'horzLineValue',0,... % plot a threshold on pressure sensor plot
    'chStartingRef',[241,242,243,244],... % for generateSquarePulse
    'specialNumbers',[241,242,243,244],... % special number for inspecting
    'squareAmplitudePlot',1,...
    'plotStem',0,...
    ...
    'pulsePeriod',1/50,... % seconds
    'pulseDuration',200e-6,... % seconds
    'intraGap',22e-6,... % seconds
    'interPulseFromDiffChannelDelay',0.71e-3,... % seconds
    'constantConversion',[0.0052, 12.885, -7.0055]);

odinparam.legendName = {'A0'; 'A1'; 'A2'; 'A3'; 'Up'; 'Down'; 'Enable'; 'Threshold'};        
% specialNumbers = [16,17,18,19,81,82,65,97]; % special number for inspecting

% Filtering Parameters
dataToBeFiltered = 'dataRaw'; % input 'dataRaw' for raw data; input 'dataDifferential' for differential data; input 'dataRectified' for rectified data
highPassCutoffFreq = 30; % high pass cutoff frequency, input 0 if not applied
lowPassCutoffFreq = 500; % low pass cutoff frequency, input 0 if not applied
notchFreq = 50; % notch frequency, input 0 if not applied
downSamplingFreq = 0; % down sampling the data to the sampling rate of downSamplingFrequency; input 0 to deactivate
pcaCleaning = 0; % run PCA to omit principle components that have very little latent (eigenvalues), default threshold is 50 percentile

% FFT parameters
dataToBeFFT = 'dataFiltered'; % input 'dataRaw' for raw data; input 'dataFiltered' for filtered data; input 'dataRectified' for rectified data; input 'dataDifferential' for differential data

% Peak Detection Parameters
dataToBeDetectedSpike = 'dataTKEO'; % data for spike detecting
overlappedWindow = 'dataFiltered'; % Select window for overlapping. Input 'dataRaw' for raw data, 'dataFiltered' for filtered data, 'dataDifferential' for differential data
spikeDetectionType = 'TKEO'; % input 'local maxima' for local maxima, input 'trigger for first point exceeding threshold, input 'TKEO' for taking following consecutive points into account
threshold = [0]; % specified one threshold for spikes detection in all the channels; multiple thresholds are allowed for different channels; input 0 for default value (baseline + threshMult * baselineStandardDeviation) (baseline is obtained by calculating the mean of the data points spanned between 1/4 to 3/4 of the data array sorted by amplitudes)
threshStdMult = [3,1]; % multiples of standard deviation above the baseline as the threshold for TKEO detection. All channels will use the same value if there is only one value, multiple values are allowed for different channels
sign = 1; % input 1 for threhoslding upwards, input -1 for thresholding downwards
windowSize = [0.03, 0.07]; % range of window starting from the detected peaks(in seconds)
channelExtractStartingLocs = 0; % input channel index (start from 1, then 2, 3...) to fix the locs for all the channels, windows between 2 consecutive starting points of the bursts will be extracted and overlapped. Input 0 to deactivate this function
TKEOStartConsecutivePoints = [25,20]; % number of consecutive points over the threshold to be detected as burst
TKEOEndConsecutivePoints = [25,100]; % number of consecutive points below the threshold to be detected as end of burst
burstTrimming = 0; % to exclude the bursts by inputting the bursts indexes
burstTrimmingType = 1; % 1 to delete; 2 to pick

% Show & Save Plots Parameters. Input 1 to save/show, otherwise input 0.
% Plots will be saved in the folder 'Figures' at the same path with the processed data 
showRaw = 1;
showDifferential = 0;
showRectified = 0;
showFilt = 0;
showOverlap = 0;
showFFT = 0;

saveRaw = 0;
saveDifferential = 0;
saveRectified = 0;
saveFilt = 0;
saveOverlap = 0;
saveFFT = 0;

saveUserInput = 0; % set to 1 to save all the information, otherwise set to 0

%% Main
ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis(dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelPair,samplingFreq,partialDataSelection,constraintWindow,neutrinoInputReferred,neutrinoBit,downSamplingFreq,saveOverlap,showOverlap,saveFFT,showFFT);
disp([num2str(toc(ticDataAnalysis)), ' seconds is used for loading and processing data...'])
disp(' ')

%% Locate bursts and select windows around them
tic
if showOverlap==1 || saveOverlap==1 % peaks detection is only activated when either showOverlap or saveOverlap or both of them are TRUE
    signalClassification = dataClassificationPreparation(signal, iter, pcaCleaning, overlappedWindow, windowSize,dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType);
else
    signalClassification = 1;
end
disp([num2str(toc),' seconds is used for classification preparation...'])
disp(' ')

%% Plot selected windows
close all

tic
windowsValues = visualizeSignals(signal, signalClassification, odinparam, overlappedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT);
disp ([num2str(toc), ' seconds is used for visualizing signals...'])
disp(' ')

%% Ending
tic
if saveUserInput
    for i = 1:length(signal)
        saveVar([signal(i,1).path,'\Info\'],signal(i,1).fileName,signal,signalClassification,windowsValues)
    end
end
disp ([num2str(toc), ' seconds is used for saving info...'])
disp(' ')

finishMsg()

% changeValue;

