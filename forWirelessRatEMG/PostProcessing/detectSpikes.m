function output = detectSpikes(data)
%detectSpikes Summary of this function goes here
%   Detailed explanation goes here

[rowData, colData] = size(data);

for i = 1:colData
    maxPeak = max(data(:,i));
    
    threshold = maxPeak / 2;
    
    [spikePeaksValue{i,1}, spikeLocs{i,1}] = findpeaks(data(:,i),'minPeakHeight',threshold);
end

output.spikePeaksValue = spikePeaksValue;
output.spikeLocs = spikeLocs;
   
end

