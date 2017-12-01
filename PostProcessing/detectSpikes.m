function output = detectSpikes(data, minDistance, threshold, sign, type, TKEOStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints)
%detectSpikes After taking baseline into account, any sample point exceeds
%3/5 of the maximum value of the signal will be considered as a spike. No 2
%spikes will be detected in one window.
%   output = detectSpikes(data, minDistance, threshold, sign, type, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints)

if nargin < 2
    minDistance = 1;
    threshold = 0;
    sign = 1;
    type = 'threshold';
    TKEOStdMult = 1;
    TKEOStartConsecutivePoints = 1;
    TKEOEndConsecutivePoints = 1;
end


%% Find Peaks
data = sign*data;

[rowData, colData] = size(data);

if minDistance > rowData
    error('Error found in User Input: windowSize is too large, which exceeds overall recording time of signal')
end

skipWindow = floor(minDistance);

for i = 1:colData % channel
    maxPeak = max(data(:,i));
    baseline{i,1} = baselineDetection(sign * data(:,i));
    if threshold == 0 % if no user input, 3/4 of maximum value will be used as threshold value
        if isequal(type,'TKEO')
            thresholdValue = sign * baseline{i,1}.mean + TKEOStdMult * baseline{i,1}.std;
        else
            thresholdValue = sign * baseline{i,1}.mean + (maxPeak - sign * baseline{i,1}.mean) *3/4;
        end
    else
        thresholdValue = threshold;
    end
    
    switch type
        case 'threshold'
            [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(skipWindow:end-skipWindow,i),'minPeakHeight',... % find peaks starting from minDistance of the data onwards
                thresholdValue,'minPeakDistance',minDistance);
            spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance,spikeLocs{i,1});
        case 'trigger'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(skipWindow:end-skipWindow,i),thresholdValue,minDistance);
            spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = pointAfterAWindow(data(:,i),minDistance,spikeLocs{i,1});
        case 'TKEO'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(skipWindow:end-skipWindow,i),thresholdValue,minDistance,TKEOStartConsecutivePoints); % the last value is the number of consecutive point that needs to exceed threshold to be detected as spikes
            spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
            [burstEndValue{i,1},burstEndLocs{i,1}] = findEndPoint(data(:,i), thresholdValue, spikeLocs{i,1}, TKEOEndConsecutivePoints);
            [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] =...
                trimBurstLocations(spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1});
            % another way to detect TKEO bursts
%             [spikePeaksValue{i,1},spikeLocs{i,1},burstEndValue{i,1},burstEndLocs{i,1}] = ...
%                 TKEOSpikeDetection(data(skipWindow:end-skipWindow,i),thresholdValue,TKEOStartConsecutivePoints,TKEOEndConsecutivePoints); % the last value is the number of consecutive point that needs to exceed threshold to be detected as spikes
%             spikeLocs{i,1} = spikeLocs{i,1} + skipWindow - 1; % compensate the skipped window
%             burstEndLocs{i,1} = burstEndLocs{i,1} + skipWindow -1; % compensate the skipped window
        otherwise
    end
    
    thresholdAll(i,1) = thresholdValue;
end

%% reconstruct spikePeaksValue and spikeLocs
if isempty(spikePeaksValue{1,1})
    error('No spikes detected, absolute threshold is higher than all the points...')
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
end

