function varargout = mainClassifier(varargin)
%% Main code for Signal analysis
% Features data filtering, burst detecting, windows overlapping,
% figures displaying and saving, bursts classification
%
% output: varargout: signal, signalClassificationInfo, windowsValues,
% parameters
% 
% Coded by Tsai Chne Wuen

% close all
deleteMsgBox(); % delete all the message boxes
% clc

%% User's Input
% General Parameters
parameters = struct(...
    'dataType','neutrino2',... % configurable types: ,'neutrino2','neutrino', 'intan', 'sylphx', 'sylphii'
    'channel',[1,2],... % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
    'channelAveragingFlag',1,...  % use the channelAveraging below to do the average
    'channelPair',0,...; % input the pairs seperated in rows, eg:[1,2;3,4] means 1 pairs with 2 and 3 pairs with 4; input 0 if no differential data is needed.
    'samplingFreq',0,... % specified sampling frequency, otherwise input 0 for default value (Neutrino: 3e6/14/12, intan: 20000, sylphX: 1798.2, sylphII: 1798.2)
    'neutrinoInputReferred',0,...; % input 1 to check input refer, otherwise input 0
    'neutrinoBit',0,...; % input 1 for 8 bit mode, input 0 for 10 bit mode
    'selectFile',2,... % 1 to select file manually, 0 to select all the files in the current directories, 2 to use the specific path stored in specificPath
    'specificTarget','data_20190313_144318_250muA.csv',... 'NHP_Neuroma_190327_122547_60muA.rhd',... 'Neuroma_NHP201903_190313_131918_240muA.rhd',... % it will only be activated when selectFile is equal to 2
    'padZeroFlag',0,... % 1 to pad zero
    ...
    'partialDataSelection',0,...; % input 1 to select partial data to analyse, otherwise input 0
    'constraintWindow',[-0.30075,6.9049],... % starting point and end point of constraint window, unit is in seconds. Input 0 for default (pre-select the whole signal). It can be found in signal.analysedDataTiming(2,:), the first row is the timing in seconds
    'markBurstInAllChannels',0,... % mark all the channels when one of the channels detects a burst
    'burstLen',0,... % fix the length of the detected bursts, input zero if not enabling it
    'getBaselineFeatureFlag',1,... % get the features of the baseline, which is the data that are not marked as bursts
    'baselineType','invert',... % either 'inverrt', 'sorted', or 'movingWindow': 'invert' will choose the sections that are not bursts, while 'sorted' will choose sort the data ascendingly and choose the middle part as baseline, 'movingWindow' will use either the largest burst length or 500 ms as window size and sweeping through to search for the window that doesn't have points exceeding threshold
    ...
    ...% Filtering Parameters
    'dataToBeFiltered','dataRaw',...; % input 'dataRaw' for raw data; input 'dataDifferential' for differential data; input 'dataRectified' for rectified data
    'highPassCutoffFreq',300,... % high pass cutoff frequency, input 0 if not applied
    'lowPassCutoffFreq',5000,... % low pass cutoff frequency, input 0 if not applied
    'notchFreq',50,... % notch frequency, input 0 if not applied
    'downSamplingFreq',0,... % down sampling the data to the sampling rate of downSamplingFrequency; input 0 to deactivate
    'pcaCleaning',0,... % run PCA to omit principle components that have very little latent (eigenvalues), default parameters.threshold is 50 percentile
    ...
    ...% FFT parameters
    'dataToBeFFT','dataFiltered',... % input 'dataRaw' for raw data; input 'dataFiltered' for filtered data; input 'dataRectified' for rectified data; input 'dataDifferential' for differential data
    ...
    ...% Peak Detection Parameters
    'dataToBeDetectedSpike','dataFiltered',... % data for spike detecting
    'overlappedWindow','dataFiltered',... % Select window for overlapping. Input 'dataRaw', 'dataFiltered', 'dataDifferential', 'dataTKEO'
    'spikeDetectionType','trigger',... % input 'local maxima' for local maxima, input 'trigger for first point exceeding parameters.threshold, input 'TKEO' for taking following consecutive points into account
    ...
    'threshold', [7e-3],... %[0.2e-4],... % specified one parameters.threshold for spikes detection in all the channels; multiple thresholds are allowed for different channels; input 0 for default value (baseline + threshMult * baselineStandardDeviation) (baseline is obtained by calculating the mean of the data points spanned between 1/4 to 3/4 of the data array sorted by amplitudes)
    'threshStdMult',[25,20,20,20],... % multiples of standard deviation above the baseline as the parameters.threshold for TKEO detection. All channels will use the same value if there is only one value, multiple values are allowed for different channels
    'sign',1,... % input 1 for threhoslding upwards, input -1 for thresholding downwards
    ...
    'windowSize', [0, 2.5e-3],... %[0, 0.02],... % range of window starting from the detected peaks(in seconds)
    'overlapWindowLengthMult',0,...  % multiplier to set the overlap window length
    'channelExtractStartingLocs',0,... % input parameters.channel index (start from 1, then 2, 3...) to fix the locs for all the channels, windows between 2 consecutive starting points of the bursts will be extracted and overlapped. Input 0 to deactivate this function
    'trainingRatio',0.7,... % training ratio for classifier
    ...
    'dataThresholdOmitFlag',1,... % flag to omit data found in peak detection
    'windowSizeThresholdOmit',[-0.0002, 0.0202],...  % to omit the data found from peak detection
    'stitchFlag','stitch',...  % 'interpolate' to interpolate, 'stitch' to stitch two ends together, 'remain' to remain the time stamps
    'remainBurstLocs',0,...  % use the bursts locations found in first round
    ...
    'restoreSyncPulseFlag',1,...  % restore the missing signal based on the detected spikes and their location 
    'restoreInterSpikeSeparation',300,...  % (Hz) distance between detected spikes to use as trace for restoration
    'restoreInterStimulationSeparation',1,...  % (second) distance between each train
    'restoreNumSpikes',7,...  % number of spike in one train
    'restoreInterTrainFrequency',46.3,...  % (Hz) distance between two trains of spikes
    'restoreTolerance',0.0003,...  % (second) tolerance for the spikes to distant from each other
    ...
    'dataPeriodicOmitFrequency',0,... % frequency of the chunk to be omitted (Hz), input 0 to deactivate
    'dataPeriodicOmitWindowSize',0.0007,... % window size to periodically omit it (seconds)
    'dataPeriodicOmitStartingPoint',2.4291,... % starting point to periodically omit data chunk (seconds)
    ...
    'TKEOStartConsecutivePoints',[35],... % number of consecutive points over the parameters.threshold to be detected as burst
    'TKEOEndConsecutivePoints',[100],... % number of consecutive points below the parameters.threshold to be detected as end of burst
    'burstTrimming',0,... % to exclude the bursts by inputting the bursts indexes
    'burstTrimmingWay','drag',... % 'key' to key in zeros, end the process by entering 0; 'drag' to drag the area that containst the burst, end the process by hitting 'Enter'
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
    'showCompare',0,...
    'showSyncPulse',1,...  % input 1 or 0, plot raw channel 11 in Compare Plot
    'showCounter',0,...  % input 1 or 0, plot raw channel 13 in Compare Plot
    'showRaster',1,...  % input zero to get the raster plots
    ...
    'saveRaw',0,...
    'saveDifferential',0,...
    'saveRectified',0,...
    'saveFilt',0,...
    'saveOverlap',0,...
    'saveFFT',0,...
    'saveCompare',0,...
    'saveRaster',0,...
    ...
    'noClassification',0,...
    'saveUserInput',0); % set to 1 to save all the information, otherwise set to 0

parameters.channelAveraging = [{[1,2,3,4,5]} ; {[6,7,8,9,10]}];  % average the channels stored in each cell, example:[{[1,2]};{[3,4,5]}], then it will average 1&2, then do another average on 3&4&5
% parameters.channelAveraging = [{[9,13,14,17,21]};{[1,5,25,29,30]}];  % average the channels stored in each cell, example:[{[1,2]};{[3,4,5]}], then it will average 1&2, then do another average on 3&4&5

% load the input variables into parameters
parameters = varIntoStruct(parameters,varargin);

% Plotting Parameters
PPYUnit = 'V';
PPYLimit = 'auto';
% PPYLimit = [-8e-5,8e-5];

PP = struct(...
    'overlappingYUnit',PPYUnit,...  % possible input: '\muV', 'mV', 'V'
    'filteredYUnit',PPYUnit,...
    'rawYUnit',PPYUnit,...
    'overallYUnit',PPYUnit,...
    'averageYUnit',PPYUnit,...
    ...
    'overlappingYLimit',PPYLimit,...  % [a,b] as make y axis from a to b, otherwise input 'auto' for auto fitting
    'filteredYLimit',PPYLimit,...
    'rawYLimit',PPYLimit,...
    'overallYLimit',PPYLimit,...
    'averageYLimit',PPYLimit);

%% Main
ticDataAnalysis = tic;
popMsg('Start Analysing...')
[signal, signalName, iter] = dataAnalysis(parameters);
popMsg([num2str(toc(ticDataAnalysis)), ' seconds is used for loading and processing data...'])
disp(' ')
    
%% Locate bursts and select windows around them
signalClassification = nan;
rasterLocs = nan;

if ~parameters.noClassification || parameters.showOverlap || parameters.saveOverlap
    tic
    popMsg('Start locting bursts...')
    % if parameters.showOverlap==1 || parameters.saveOverlap==1 % peaks detection is only activated when either parameters.showOverlap or parameters.saveOverlap or both of them are TRU
    signalClassification = dataClassificationPreparation(signal, iter, parameters);
    
    % else
    %     signalClassification = 1;
    % end
    if parameters.dataThresholdOmitFlag  % omit a chunk of data after detecting the bursts
        if parameters.restoreSyncPulseFlag
            restorationOutput = restoreSignal(signalClassification.burstDetection.spikeLocs, parameters, signal.samplingFreq);
            omitThresholdOutput = omitThresholdData(signal, restorationOutput.locsTrainMajor, parameters);
        else
            omitThresholdOutput = omitThresholdData(signal, signalClassification.burstDetection.spikeLocs, parameters);
        end
        
        signal = omitThresholdOutput.signal;
        
        if parameters.remainBurstLocs
            parameters.spikeDetectionType = 'fixed';
            parameters.spikeLocsFixed = omitThresholdOutput.startingPoint;
        else
            parameters.stitchFlag = 'trigger';
            parameters.windowSize = [0, 0.001];
            parameters.threshold = 8e-3; %2e-6; %2.5e-6;
        end
        
        tic
        popMsg('Start locting bursts...')
        % if parameters.showOverlap==1 || parameters.saveOverlap==1 % peaks detection is only activated when either parameters.showOverlap or parameters.saveOverlap or both of them are TRU
        signalClassification = dataClassificationPreparation(signal, iter, parameters);
        
        % else
        %     signalClassification = 1;
        % end
        rasterLocs = omitThresholdOutput.startingPoint;
    end
    
    popMsg([num2str(toc),' seconds is used for classification preparation...'])
    disp(' ')
        
    writeBurstIndexInfo(signal,signalClassification,parameters); % write the selected burst index info into info.xlsx

end


%% Plot selected windows
% close all

tic
popMsg('Visualizing signals...')
windowsValues = visualizeSignals(signal, signalClassification, rasterLocs, parameters, PP);
popMsg([num2str(toc), ' seconds is used for visualizing signals...'])
disp(' ')

%% Ending
tic
popMsg('Saving .mat files...')
if parameters.saveUserInput
    for i = 1:length(signal)
        saveFileName{1,i} = saveVar([signal(i,1).path,'Info',filesep],signal(i,1).fileName,signal(i,1),signalClassification(i,1),windowsValues(i,1),parameters);
    end
end
popMsg([num2str(toc), ' seconds is used for saving info...'])
disp(' ')

%% output
if nargout >= 1; varargout{1,1} = signal;
    if nargout >= 2; varargout{1,2} = signalClassification;
        if nargout >= 3; varargout{1,3} = saveFileName;
            if nargout >= 4; varargout{1,4} = windowsValues;
                if nargout >=5; varargout{1,5} = parameters;
                end
            end
        end
    end
end

popMsg('Finished...')


end