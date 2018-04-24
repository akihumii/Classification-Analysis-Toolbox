function output = detectSpikes(data, minDistance, threshold, sign, type, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints)
%detectSpikes After taking baseline into account, any sample point exceeds
%3/5 of the maximum value of the signal will be considered as a spike. No 2
%spikes will be detected in one window.
% 
% input: type: can be 'local maxima', 'trigger', 'TKEO'
% 
% output: spikePeaksValue,spikeLocs,threshold,baseline,burstEndValue,burstEndLocs,threshStdMult,TKEOStartConsecutivePoints,TKEOEndConsecutivePoints,warningOn
% 
%   output = detectSpikes(data, minDistance, threshold, sign, type, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints)

if nargin < 2
    minDistance = [1,1];
    threshold = 0;
    sign = 1;
    type = 'threshold';
    threshStdMult = 1;
    TKEOStartConsecutivePoints = 1;
    TKEOEndConsecutivePoints = 1;
end    

%% Find Peaks
data = sign*data;

[rowData, colData] = size(data);

if minDistance(2) > rowData
    error('Error found in User Input: windowSize is too large, which exceeds overall recording time of signal')
end

if length(threshStdMult) == 1
    threshStdMult = repmat(threshStdMult,1,colData);
end
if length(TKEOStartConsecutivePoints) == 1
    TKEOStartConsecutivePoints = repmat(TKEOStartConsecutivePoints,1,colData);
end
if length(TKEOEndConsecutivePoints) == 1
    TKEOEndConsecutivePoints = repmat(TKEOEndConsecutivePoints,1,colData);
end

minDistance = floor(minDistance);

for i = 1:colData % channel
    maxPeak = max(data(:,i));
    baseline{i,1} = baselineDetection(sign * data(:,i)); % the mean of the data points spanned from 1/4 to 3/4 of the data sorted by amplitude is obtained as baseline
    if threshold == 0 % if no user input, baseline + threshStdMult * baselineStandardDeviation will be used as threshold value
            thresholdValue = sign * baseline{i,1}.mean + threshStdMult(1,i) * baseline{i,1}.std;
    elseif length(threshold) == 1
        thresholdValue = sign * threshold(1,1);
    else
        thresholdValue = sign * threshold(1,i);
    end
    
    switch type
        case 'local maxima'
            [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(minDistance(1):end-minDistance(2)-1,i),'minPeakHeight',... % find peaks starting from minDistance of the data onwards
                thresholdValue,'minPeakDistance',minDistance(2));
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance(2),spikeLocs{i,1});
        case 'trigger'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2)-1,i),thresholdValue,minDistance(2));
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance(2),spikeLocs{i,1});
        case 'TKEO'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2)-1,i),thresholdValue,minDistance(2),TKEOStartConsecutivePoints(1,i)); % the last value is the number of consecutive point that needs to exceed threshold to be detected as spikes
%             [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(minDistance(1):end-minDistance(2),i),thresholdValue,minDistance(2),TKEOStartConsecutivePoints); % the last value is the number of consecutive point that needs to exceed threshold to be detected as spikes
            spikeLocs{i,1} = spikeLocs{i,1} + minDistance(1); % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = findEndPoint(data(:,i), thresholdValue, spikeLocs{i,1}, TKEOEndConsecutivePoints(1,i));
            [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] =...
                trimBurstLocations(spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1});
            % another way to detect TKEO bursts
%             [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] = ...
%                 TKEOSpikeDetection(data(skipWindow:end-skipWindow,i),thresholdValue,TKEOStartConsecutivePoints,TKEOEndConsecutivePoints); % the last value is the number of consecutive point that needs to exceed threshold to be detected as spikes
%             spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
%             burstEndLocs{i,1} = burstEndLocs{i,1} + skipWindow -1; % compensate the skipped window
        otherwise
            error('Invalid spike detection type')
    end
    
    thresholdAll(i,1) = thresholdValue;
end

%% reconstruct spikePeaksValue and spikeLocs
if isempty(spikePeaksValue{1,1})
    warning('No spikes detected, absolute threshold is higher than all the points...')
end

spikePeaksValue = cell2nanMat(spikePeaksValue);
spikeLocs = cell2nanMat(spikeLocs);
burstEndValue = cell2nanMat(burstEndValue);
burstEndLocs = cell2nanMat(burstEndLocs);

output.spikePeaksValue = sign * spikePeaksValue;
output.spikeLocs = spikeLocs;
output.threshold = sign * thresholdAll;
output.baseline = baseline;
output.burstEndValue = burstEndValue;
output.burstEndLocs = burstEndLocs;
output.threshStdMult = threshStdMult;
output.TKEOStartConsecutivePoints = TKEOStartConsecutivePoints;
output.TKEOEndConsecutivePoints = TKEOEndConsecutivePoints;
end

