function output = dataClassificationPreparation(signal, pcaCleaning, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType)
%dataClassification Detect windows, extract features, execute
%classification
%   output = dataClassificationPreparation(signal, iter, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, treshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType)

% for the case of selected filtered data, because the values lies in the
% field 'values' of the structure 'dataFiltered'.

if isequal(selectedWindow, 'dataFiltered')
    selectedWindow = [{'dataFiltered'};{'values'}];
end

output(1,1) = classClassificationPreparation; % pre-allocation

output = classClassificationPreparation(signal.file,signal.path,windowSize); % create object 'output'

% detect spikes
output = detectSpikes(output, signal, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs);

% get windows around spikes
output = classificationWindowSelection(output, signal, selectedWindow,burstTrimming,burstTrimmingType);

% clean the bursts by running PCA
if pcaCleaning
    output = pcaCleanData(output);
end

% extract features
output = featureExtraction(output,signal.samplingFreq,[{'selectedWindows'};{'burst'}]); % [1 * number of windows * number of sets]

% group features for classification
output = classificationGrouping(output,'maxValue',1);

end

