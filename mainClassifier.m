function varargout = mainClassifier(varargin)
%% Main code for Signal analysis
% Features data filtering, burst detecting, windows overlapping,
% figures displaying and saving, bursts classification
%
% output: varargout: signal, signalClassificationInfo, windowsValues,
% parameters
% 
% Coded by Tsai Chne Wuen

close all hidden
delete(timerfindall)
% clc

%% User's Input
% General Parameters
parameters = struct(...
    'dataType','sylphx',... % configurable types: ,'neutrino2','neutrino', 'intan', 'sylphx', 'sylphii'
    'channel',6:7,... % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
    'channelPair',0,...; % input the pairs seperated in rows, eg:[1,2;3,4] means 1 pairs with 2 and 3 pairs with 4; input 0 if no differential data is needed.
    'samplingFreq',0,... % specified sampling frequency, otherwise input 0 for default value (Neutrino: 3e6/14/12, intan: 20000, sylphX: 1798.2, sylphII: 1798.2)
    'neutrinoInputReferred',0,...; % input 1 to check input refer, otherwise input 0
    'neutrinoBit',1,...; % input 1 for 8 bit mode, input 0 for 10 bit mode
    'selectFile',1,... % 1 to select file manually, 0 to select all the files in the current directories, 2 to use the specific path stored in specificPath, 3 to specify a file
    'specificTarget','',... % it will only be activated when selectFile is equal to 2
    ...
    'partialDataSelection',0,...; % input 1 to select partial data to analyse, otherwise input 0
    'constraintWindow',[-0.30075,6.9049],... % starting point and end point of constraint window, unit is in seconds. Input 0 for default (pre-select the whole signal). It can be found in signal.analysedDataTiming(2,:), the first row is the timing in seconds
    'markBurstInAllChannels',1,... % mark all the channels when one of the channels detects a burst
    'getBaselineFeatureFlag',1,... % get the features of the baseline, which is the data that are not marked as bursts
    ...
    ...% Filtering Parameters
    'dataToBeFiltered','dataRaw',...; % input 'dataRaw' for raw data; input 'dataDifferential' for differential data; input 'dataRectified' for rectified data
    'highPassCutoffFreq',30,... % high pass cutoff frequency, input 0 if not applied
    'lowPassCutoffFreq',500,... % low pass cutoff frequency, input 0 if not applied
    'notchFreq',50,... % notch frequency, input 0 if not applied
    'downSamplingFreq',0,... % down sampling the data to the sampling rate of downSamplingFrequency; input 0 to deactivate
    'pcaCleaning',0,... % run PCA to omit principle components that have very little latent (eigenvalues), default parameters.threshold is 50 percentile
    ...
    ...% FFT parameters
    'dataToBeFFT','dataFiltered',... % input 'dataRaw' for raw data; input 'dataFiltered' for filtered data; input 'dataRectified' for rectified data; input 'dataDifferential' for differential data
    ...
    ...% Peak Detection Parameters
    'dataToBeDetectedSpike','dataTKEO',... % data for spike detecting
    'overlappedWindow','dataFiltered',... % Select window for overlapping. Input 'dataRaw', 'dataFiltered', 'dataDifferential', 'dataTKEO'
    'spikeDetectionType','TKEO',... % input 'local maxima' for local maxima, input 'trigger for first point exceeding parameters.threshold, input 'TKEO' for taking following consecutive points into account
    ...
    'threshold',[0],... % specified one parameters.threshold for spikes detection in all the channels; multiple thresholds are allowed for different channels; input 0 for default value (baseline + threshMult * baselineStandardDeviation) (baseline is obtained by calculating the mean of the data points spanned between 1/4 to 3/4 of the data array sorted by amplitudes)
    'threshStdMult',[10,20],... % multiples of standard deviation above the baseline as the parameters.threshold for TKEO detection. All channels will use the same value if there is only one value, multiple values are allowed for different channels
    'sign',1,... % input 1 for threhoslding upwards, input -1 for thresholding downwards
    ...
    'windowSize',[0.03, 0.07],... % range of window starting from the detected peaks(in seconds)
    'channelExtractStartingLocs',0,... % input parameters.channel index (start from 1, then 2, 3...) to fix the locs for all the channels, windows between 2 consecutive starting points of the bursts will be extracted and overlapped. Input 0 to deactivate this function
    'trainingRatio',0.7,... % training ratio for classifier
    ...
    'TKEOStartConsecutivePoints',[35],... % number of consecutive points over the parameters.threshold to be detected as burst
    'TKEOEndConsecutivePoints',[100,200],... % number of consecutive points below the parameters.threshold to be detected as end of burst
    'burstTrimming',0,... % to exclude the bursts by inputting the bursts indexes
    'burstTrimmingType',1,... % 1 to delete; 2 to pick
    ...
    ...% Show & Save Plots Parameters. Input 1 to save/show, otherwise input 0.
    ...% Plots will be saved in the folder 'Figures' at the same path with the processed data
    'showRaw',0,...
    'showDifferential',0,...
    'showRectified',0,...
    'showFilt',0,...
    'showOverlap',1,...
    'showFFT',0,...
    ...
    'saveRaw',0,...
    'saveDifferential',0,...
    'saveRectified',0,...
    'saveFilt',0,...
    'saveOverlap',0,...
    'saveFFT',0,...
    ...
    'saveUserInput',1); % set to 1 to save all the information, otherwise set to 0

% load the input variables into parameters
parameters = varIntoStruct(parameters,varargin);

%% Main
ticDataAnalysis = tic;
popMsg('Start Analysing...')
[signal, signalName, iter] = dataAnalysis(parameters);
popMsg([num2str(toc(ticDataAnalysis)), ' seconds is used for loading and processing data...'])
disp(' ')

%% Locate bursts and select windows around them
tic
popMsg('Start locting bursts...')
% if parameters.showOverlap==1 || parameters.saveOverlap==1 % peaks detection is only activated when either parameters.showOverlap or parameters.saveOverlap or both of them are TRUE
signalClassification = dataClassificationPreparation(signal, iter, parameters);

writeBurstIndexInfo(signal,signalClassification,parameters); % write the selected burst index info into info.xlsx
% else
%     signalClassification = 1;
% end
popMsg([num2str(toc),' seconds is used for classification preparation...'])
disp(' ')

%% Plot selected windows
close all

tic
popMsg('Visualizing signals...')
windowsValues = visualizeSignals(signal, signalClassification, parameters);
popMsg([num2str(toc), ' seconds is used for visualizing signals...'])
disp(' ')

%% Ending
tic
popMsg('Saving .mat files...')
if parameters.saveUserInput
    for i = 1:length(signal)
        saveVar([signal(i,1).path,filesep,'Info',filesep],signal(i,1).fileName,signal(i,1),signalClassification(i,1),windowsValues(i,1),parameters);
    end
end
popMsg([num2str(toc), ' seconds is used for saving info...'])
disp(' ')

%% output
if nargout >= 1; varargout{1,1} = signal;
    if nargout >= 2; varargout{1,2} = signalClassification;
        if nargout >= 3; varargout{1,3} = windowsValues;
            if nargout >=4; varargout{1,4} = parameters;
            end
        end
    end
end

popMsg('Finished...')


end