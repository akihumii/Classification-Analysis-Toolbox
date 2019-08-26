function [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
         subsampleBursts(data, burstLen, stepWindowSize, spikeLocs, burstEndLocs)
%SUBSAMPLEBURSTS Subsample bursts into burstLen with stepsize stepWindowSize
%   Detailed explanation goes here
dataCol = size(data,2);

for i = 1:dataCol
    numBursts = sum(~isnan(spikeLocs(:,i)));
    spikeLocsAllSeparated{1,i} = [];
    burstEndLocsSeparated{1,i} = [];
    for j = 1:numBursts
        if burstEndLocs(j,i) + burstLen <= size(data,1);
            startingPointTemp = transpose(spikeLocs(j,i) : stepWindowSize : burstEndLocs(j,i));
            spikeLocsAllSeparated{j,i} = startingPointTemp;
            burstEndLocsSeparated{j,i} = startingPointTemp + burstLen;
        end
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

