function output = detectSpikes(data, minDistance)
%detectSpikes After taking baseline into account, any sample point exceeds 
%3/5 of the maximum value of the signal will be considered as a spike. No 2
%spikes will be detected in one window.
%   output = detectSpikes(data, minDistance)

if nargin < 2
    minDistance = 1;
end

%% Find Peaks
[rowData, colData] = size(data);
thresholdValue = 3/5;

for i = 1:colData % channel
    maxPeak = max(data(:,i));
    baseline(i,1) = baselineDetection(data(:,i));
    threshold(i,1) = baseline(i,1) + (maxPeak - baseline(i,1)) * thresholdValue;
    
    [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(:,i),'minPeakHeight',threshold(i,1),'minPeakDistance',minDistance);
end

%% reconstruct spikePeaksValue and spikeLocs
spikePeaksValue = cell2nanMat(spikePeaksValue);
spikeLocs = cell2nanMat(spikeLocs);

output.spikePeaksValue = spikePeaksValue;
output.spikeLocs = spikeLocs;
output.threshold = threshold;
output.baseline = baseline;

end

