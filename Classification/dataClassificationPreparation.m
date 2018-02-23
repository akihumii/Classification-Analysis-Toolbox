function output = dataClassificationPreparation(signal, iter, pcaCleaning, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType)
%dataClassification Detect windows, extract features, execute
%classification
%   output = dataClassificationPreparation(signal, iter, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, treshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType)

% for the case of selected filtered data, because the values lies in the
% field 'values' of the structure 'dataFiltered'.

if isequal(selectedWindow, 'dataFiltered')
    selectedWindow = [{'dataFiltered'};{'values'}];
end

output(iter,1) = classClassificationPreparation; % pre-allocation

for i = 1:iter
output(i,1) = classClassificationPreparation(signal(i,1).file,signal(i,1).path,windowSize); % create object 'output'

% detect spikes
output(i,1) = detectSpikes(output(i,1), signal(i,1), dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs);

% get windows around spikes
output(i,1) = classificationWindowSelection(output(i,1), signal(i,1), selectedWindow,burstTrimming,burstTrimmingType);

% extract features
output(i,1) = featureExtraction(output(i,1),signal(i,1).samplingFreq,[{'selectedWindows'};{'burst'}]); % [1 * number of windows * number of sets]

% group features for classification
output(i,1) = classificationGrouping(output(i,1),'maxValue',i);
end

end

