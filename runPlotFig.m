%% Run show figures only
mainClassifier(...
    'showRaw',1,...
    'showFilt',0,...
    'channel',[1:2],... % channels to be processed. Consecutive channels can be exrpessed with ':'; Otherwise separate them with ','.
    'samplingFreq',30000,... % specified sampling frequency, otherwise input 0 for default value (Neutrino: 3e6/14/12, intan: 20000, sylphX: 1798.2, sylphII: 1798.2)
    'threshold', [70],... %[0.2e-4],... % specified one parameters.threshold for spikes detection in all the channels; multiple thresholds are allowed for different channels; input 0 for default value (baseline + threshMult * baselineStandardDeviation) (baseline is obtained by calculating the mean of the data points spanned between 1/4 to 3/4 of the data array sorted by amplitudes)
    'highPassCutoffFreq',0,... % high pass cutoff frequency, input 0 if not applied
    'lowPassCutoffFreq',0,... % low pass cutoff frequency, input 0 if not applied
    'notchFreq',0,... % notch frequency, input 0 if not applied
    ...
    'noClassification',1,...  % 1 to skip burst detection, vice versa
    'showDetectedBurstsChannel',[0],...  % input 0 to show all channels, otherwise input an array to select the channels to show
    'shiftDetectedBurstLocs',-2,...  % move the detected burst by a distance
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    ...
    'dataType','intanRaw',... % configurable types: ,'neutrino2','neutrino', 'intan', 'sylphx', 'sylphii'
    'channelAveragingFlag',0,...  % use the channelAveraging below to do the average
    'channelPair',0,...; % input the pairs seperated in rows, eg:[1,2;3,4] means 1 pairs with 2 and 3 pairs with 4; input 0 if no differential data is needed.
    'neutrinoInputReferred',0,...; % input 1 to check input refer, otherwise input 0
    'neutrinoBit',0,...; % input 1 for 8 bit mode, input 0 for 10 bit mode
    'selectFile',1,... % 1 to select file manually, 0 to select all the files in the current directories, 2 to use the specific path stored in specificPath
    'specificTarget','data_20190313_144318_250muA.csv',... 'NHP_Neuroma_190327_122547_60muA.rhd',... 'Neuroma_NHP201903_190313_131918_240muA.rhd',... % it will only be activated when selectFile is equal to 2
    'padZeroFlag',0,... % 1 to pad zero
    ...
    'partialDataSelection',0,...; % input 1 to select partial data to analyse, otherwise input 0
    'constraintWindow',[-0.30075,6.9049],... % starting point and end point of constraint window, unit is in seconds. Input 0 for default (pre-select the whole signal). It can be found in signal.analysedDataTiming(2,:), the first row is the timing in seconds
    'markBurstInAllChannels',1,... % mark all the channels when one of the channels detects a burst
    'makeFirstFileBaseline',0,...  % use the moving window technique to get the baseline of the first file as bursts
    'burstLen',20/20000,... % fix the length of the detected bursts, input zero if not enabling it
    'getBaselineFeatureFlag',0,... % get the features of the baseline, which is the data that are not marked as bursts
    'baselineType','invert',... % either 'inverrt', 'sorted', or 'movingWindow': 'invert' will choose the sections that are not bursts, while 'sorted' will choose sort the data ascendingly and choose the middle part as baseline, 'movingWindow' will use either the largest burst length or 500 ms as window size and sweeping through to search for the window that doesn't have points exceeding threshold
    ...
    ...% Filtering Parameters
    'dataToBeFiltered','dataRaw',...; % input 'dataRaw' for raw data; input 'dataDifferential' for differential data; input 'dataRectified' for rectified data
    'downSamplingFreq',0,... % down sampling the data to the sampling rate of downSamplingFrequency; input 0 to deactivate
    'pcaCleaning',0,... % run PCA to omit principle components that have very little latent (eigenvalues), default parameters.threshold is 50 percentile
    ...
    ...% FFT parameters
    'dataToBeFFT','dataFiltered',... % input 'dataRaw' for raw data; input 'dataFiltered' for filtered data; input 'dataRectified' for rectified data; input 'dataDifferential' for differential data
    ...
    ...% Peak Detection Parameters
    'dataToBeDetectedSpike','dataFiltered',... % data for spike detecting
    'rectifySpikeDetectionDataFlag',1,...  % rectify the dataToBeDetectedSpike before performing spike detection
    'overlappedWindow','dataFiltered',... % Select window for overlapping. Input 'dataRaw', 'dataFiltered', 'dataDifferential', 'dataTKEO'
    'spikeDetectionType','trigger',... % input 'local maxima' for local maxima, input 'trigger for first point exceeding parameters.threshold, input 'TKEO' for taking following consecutive points into account
    'stepWindowSize', 0.05,...  % step size to use in TKEOmore mode, that a burst will be subsample to the size of burst length with separation of this stepWindowSize
    ...
    'threshStdMult',[50,50,Inf],... % multiples of standard deviation above the baseline as the parameters.threshold for TKEO detection. All channels will use the same value if there is only one value, multiple values are allowed for different channels
    'sign',1,... % input 1 for threhoslding upwards, input -1 for thresholding downwards
    ...
    'windowSize', [0, 20/20000],... %[0, 0.02],... % range of window starting from the detected peaks(in seconds)
    'overlapWindowLengthMult',0,...  % multiplier to set the overlap window length
    'channelExtractStartingLocs',0,... % input parameters.channel index (start from 1, then 2, 3...) to fix the locs for all the channels, windows between 2 consecutive starting points of the bursts will be extracted and overlapped. Input 0 to deactivate this function
    'trainingRatio',0.7,... % training ratio for classifier
    ...
    'dataThresholdOmitFlag',0,... % flag to omit data found in peak detection
    'windowSizeThresholdOmit',[-0.0002, 0.0202],...  % to omit the data found from peak detection
    'stitchFlag','stitch',...  % 'interpolate' to interpolate, 'stitch' to stitch two ends together, 'remain' to remain the time stamps
    'remainBurstLocs',0,...  % use the bursts locations found in first round
    ...
    'restoreSyncPulseFlag',0,...  % restore the missing signal based on the detected spikes and their location
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
    'optimizeTKEOFlag', 0,...  % check svm cross-validation and tune TKEO parameters accordingly
    'featuresID', [],...  % to select the features for optimizingTKEO
    'deltaLossLimit', 1e-4,...  % limit of delta loss during classifier optimization
    'lossLimit', 1e-3,...  % limit of loss during classifier optimization
    'learningRate', [20, 20, 10],...  % learning rate for TKEO number of point for onset and offset, and threshold multiplier
    'TKEOStartConsecutivePoints',[35],... % number of consecutive points over the parameters.threshold to be detected as burst
    'TKEOEndConsecutivePoints',[100],... % number of consecutive points below the parameters.threshold to be detected as end of burst
    'burstTrimming',0,... % to exclude the bursts by inputting the bursts indexes
    'burstTrimmingWay','drag',... % 'key' to key in zeros, end the process by entering 0; 'drag' to drag the area that containst the burst, end the process by hitting 'Enter'
    'burstTrimmingType',1,... % 1 to delete; 2 to pick
    ...
    'showInverseFlag',1,...
    ...
    ...% Show & Save Plots Parameters. Input 1 to save/show, otherwise input 0.
    ...% Plots will be saved in the folder 'Figures' at the same path with the processed data
    'showDifferential',0,...
    'showRectified',0,...
    'showOverlap',0,...
    'showOverall',0,...  % show everything about the overlapping analysis
    'showFFT',0,...
    'showCompare',0,...
    'showSyncPulse',0,...  % input 1 or 0, plot raw channel 11 in Compare Plot
    'showCounter',0,...  % input 1 or 0, plot raw channel 13 in Compare Plot
    'showRaster',0,...  % input zero to get the raster plots
    'showDetectedBursts',1,...  % only works when 'noClassification' is 0, show detected bursts in a separate subplot
    ...
    'saveRaw',0,...
    'saveDifferential',0,...
    'saveRectified',0,...
    'saveFilt',0,...
    'saveOverlap',0,...
    'saveOverall',0,...
    'saveFFT',0,...
    'saveCompare',0,...
    'saveRaster',0,...
    ...
    'getFeaturesFlag',0,...
    'saveMClustInfoFlag',0,...
    'saveUserInput',0);