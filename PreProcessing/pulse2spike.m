function newData = pulse2spike(data)
%pulse2spike Convert the pulse into spike 
%   newData = pulse2spike(data)

[rowData,colData] = size(data);
baselineStdMult = 5;
windowSkip = 10;

for i = 1:colData
    baselineInfo = baselineDetection(data(:,i));
    threshold = baseline.mean + baselineStdMult * basliene.std;
    dataDiff = diff(data(:,i)); % difference of the data;
    
    spikeLocs = (dataDiff > threshold) == 1; % locations of the points that exceed threshold
    spikeLocsDiff = diff(spikeLocs); % distance between each raw spike locations
    
end

end

