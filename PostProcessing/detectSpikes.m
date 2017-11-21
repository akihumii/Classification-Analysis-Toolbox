function output = detectSpikes(data, minDistance, threshold, sign, type)
%detectSpikes After taking baseline into account, any sample point exceeds
%3/5 of the maximum value of the signal will be considered as a spike. No 2
%spikes will be detected in one window.
%   output = detectSpikes(data, minDistance, threshold, sign, type)

if nargin < 2
    minDistance = 1;
    threshold = 0;
    sign = 1;
    type = 'threshold';
end


%% Find Peaks
data = sign*data;

[rowData, colData] = size(data);

if minDistance > rowData
    error('Error found in User Input: windowSize is too large, which exceeds overall recording time of signal')
end

for i = 1:colData % channel
    maxPeak = max(data(:,i));
    baseline(i,1) = baselineDetection(data(:,i));
    
    if threshold == 0 % if no user input, 3/4 of maximum value will be used as threshold value
        thresholdValue = baseline(i,1) + (maxPeak - baseline(i,1)) *3/4;
    else
        thresholdValue = threshold;
    end
        
    switch type
        case 'threshold'
            [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(:,i),'minPeakHeight',...
                thresholdValue,'minPeakDistance',minDistance);
        case 'trigger'
            [spikePeaksValue{i,1},spikeLocs{i,1}] = triggerSpikeDetection(data(:,i),thresholdValue,minDistance);
        otherwise
    end
    
    thresholdAll(i,1) = thresholdValue;

end

%% reconstruct spikePeaksValue and spikeLocs
if isempty(spikePeaksValue{1,1})
    error('No spikes detected, threshold is higher than all the points...')
end

spikePeaksValue = cell2nanMat(spikePeaksValue);
spikeLocs = cell2nanMat(spikeLocs);

output.spikePeaksValue = sign * spikePeaksValue;
output.spikeLocs = spikeLocs;
output.threshold = sign * thresholdAll;
output.baseline = sign * baseline;

end

