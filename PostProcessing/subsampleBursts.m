function [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
         subsampleBursts(data, burstLen, stepWindowSize, spikeLocs, spikePeaksValue, burstEndLocs)
%SUBSAMPLEBURSTS Subsample bursts into burstLen with stepsize stepWindowSize
%   Detailed explanation goes here
dataCol = size(data,2);

for i = 1:dataCol
    numBursts = sum(~isnan(spikeLocs(:,i)));
    for j = 1:numBursts
        startingPointTemp = transpose(spikeLocs(j,i) : stepWindowSize : burstEndLocs(j,i));
        spikeLocsAllSeparated{j,i} = startingPointTemp;
        burstEndLocsSeparated{j,i} = startingPointTemp + burstLen;
    end
    spikeLocsAll{i,1} = vertcat(spikeLocsAllSeparated{:,i});
    burstEndLocsAll{i,1} = vertcat(burstEndLocsSeparated{:,i});
    spikePeaksValueAll{i,1} = data(spikeLocsAll{i,1},i);
    burstEndValueAll{i,1} = data(burstEndLocsAll{i,1},i);
end
spikeLocs = cell2nanMat(spikeLocsAll);
burstEndLocs = cell2nanMat(burstEndLocsAll);
spikePeaksValue = cell2nanMat(spikePeaksValueAll);
burstEndValue = cell2nanMat(burstEndValueAll);

end

