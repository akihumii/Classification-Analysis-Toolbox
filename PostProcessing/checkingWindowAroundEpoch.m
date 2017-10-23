function epochLocsNew= checkingWindowAroundEpoch(data, spikeLocs, window)
%checkingWindowAroundEpoch Check if window around the epochs exceeds the
%range of data. Return a matrix structure.
%   epochLocsNew= checkingWindowAroundEpoch(data, spikeLocs, window)

[rowData, colData] = size(data);

for i = 1:colData
    spikeLocsNew = spikeLocs(:,i);
    spikeLocsNew = ...
        spikeLocsNew(spikeLocsNew - window(2) > 0 & spikeLocsNew + window (2) < rowData); % prevent outshoot of windows
    epochLocsNew{i,1} = spikeLocsNew(~isnan(spikeLocsNew)); % prevent NaN values from appearing
end

epochLocsNew = cell2nanMat(epochLocsNew);

end

