function output = detectSpikes(data, minDistance, parameters, baseline, thresholdValue)
%detectSpikes After taking baseline into account, any sample point exceeds
%3/5 of the maximum value of the parameters.signal will be considered as a spike. No 2
%spikes will be detected in one window.
% 
% input: parameters.spikeDetectionType: can be 'local maxima', 'trigger', 'TKEO'
%        parameters: threshold, sign, spikeDetectionType, threshStdMult,
%        TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,
%        markBurstInAllChannels
% 
% output: spikePeaksValue,spikeLocs,parameters.threshold,baseline,burstEndValue,burstEndLocs,parameters.threshStdMult,parameters.TKEOStartConsecutivePoints,parameters.TKEOEndConsecutivePoints,warningOn
% 
%   output = detectSpikes(data, minDistance, parameters)

if nargin < 2
    minDistance = [1,1];
    parameters.threshold = 0;
    parameters.sign = 1;
    parameters.spikeDetectionType = 'local maxima';
    parameters.threshStdMult = 1;
    parameters.TKEOStartConsecutivePoints = 1;
    parameters.TKEOEndConsecutivePoints = 1;
    parameters.markBurstInAllChannels = 0;
end    

%% Find Peaks
data = parameters.signData*data;

[rowData, colData] = size(data);

if minDistance(2) > rowData
    error('Error found in User Input: windowSize is too large, which exceeds overall recording time of parameters.signal')
end

if length(thresholdValue) == 1
    thresholdValue = repmat(thresholdValue,colData,1);
end
if length(parameters.threshStdMult) == 1
    parameters.threshStdMult = repmat(parameters.threshStdMult,1,colData);
end
if length(parameters.TKEOStartConsecutivePoints) == 1
    parameters.TKEOStartConsecutivePoints = repmat(parameters.TKEOStartConsecutivePoints,1,colData);
end
if length(parameters.TKEOEndConsecutivePoints) == 1
    parameters.TKEOEndConsecutivePoints = repmat(parameters.TKEOEndConsecutivePoints,1,colData);
end

minDistance = floor(minDistance);

for i = 1:colData % channel
    maxPeak = max(data(:,i));
    
    switch parameters.spikeDetectionType
        case 'local maxima'
            [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(minDistance(1):end-minDistance(2)-1,i),'minPeakHeight',... % find peaks starting from minDistance of the data onwards
                thresholdValue(i,1),'minPeakDistance',minDistance(2));
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance(2),spikeLocs{i,1});
        case 'trigger'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2)-1,i),thresholdValue(i,1),minDistance(2));
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance(2),spikeLocs{i,1});
        case 'TKEO'
            if length(parameters.TKEOStartConsecutivePoints) >= colData
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2)-1,i),thresholdValue(i,1),minDistance(2),parameters.TKEOStartConsecutivePoints(1,i),1); % the last value is the number of consecutive point that needs to exceed parameters.threshold to be detected as spikes
%             [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2),i),thresholdValue,minDistance(2),parameters.TKEOStartConsecutivePoints); % the last value is the number of consecutive point that needs to exceed parameters.threshold to be detected as spikes
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = findEndPoint(data(:,i), thresholdValue(i,1), spikeLocs{i,1}, parameters.TKEOEndConsecutivePoints(1,i));
            [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] =...
                trimBurstLocations(spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1});
            % another way to detect TKEO bursts
%             [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] = ...
%                 TKEOSpikeDetection(data(skipWindow:end-skipWindow,i),thresholdValue,parameters.TKEOStartConsecutivePoints,parameters.TKEOEndConsecutivePoints); % the last value is the number of consecutive point that needs to exceed parameters.threshold to be detected as spikes
%             spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
%             burstEndLocs{i,1} = burstEndLocs{i,1} + skipWindow -1; % compensate the skipped window
            else
                error('Not enough parameters.TKEOStartConsecutivePoints for all the channels...')
            end
        otherwise
            error('Invalid spike detection parameters.spikeDetectionType')
    end
end

parameters.thresholdAll = thresholdValue;

%% reconstruct spikePeaksValue and spikeLocs
if isempty(spikePeaksValue{1,1})
    warning('No spikes detected, absolute parameters.threshold is higher than all the points...')
end

spikePeaksValue = cell2nanMat(spikePeaksValue);
spikeLocs = cell2nanMat(spikeLocs);
burstEndValue = cell2nanMat(burstEndValue);
burstEndLocs = cell2nanMat(burstEndLocs);

output.spikePeaksValue = parameters.signData * spikePeaksValue;
output.spikeLocs = spikeLocs;
output.threshold = parameters.signData * parameters.thresholdAll;
output.baseline = baseline;
output.burstEndValue = burstEndValue;
output.burstEndLocs = burstEndLocs;
output.parameters.threshStdMult = parameters.threshStdMult;
output.parameters.TKEOStartConsecutivePoints = parameters.TKEOStartConsecutivePoints;
output.parameters.TKEOEndConsecutivePoints = parameters.TKEOEndConsecutivePoints;

if parameters.markBurstInAllChannels
    output = mergeChannelsInfo(data,output);
end

% if parameters.getBaselineFeatureFlag
%     output = getBaselineFeature(baseline,output);
% end

end

