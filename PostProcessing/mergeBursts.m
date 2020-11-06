function [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue, mergeType] = mergeBursts(data, parameters, spikeLocs, spikePeaksValue, burstEndLocs)
%mergeBursts Sub function to merge bursts
% [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
%       mergeBursts(data, parameters, spikeLocs, spikePeaksValue, burstEndLocs)
% Author: TSAI Chne-Wuen
% Email: eletsai@nus.edu.sg

    if strcmp(parameters.spikeDetectionType, 'TKEOmore')
        [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
            subsampleBursts(data, parameters.burstLen, parameters.stepWindowSize, spikeLocs, burstEndLocs);
        mergeType = 'just';
    else
        [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
            editBurstLen(data, parameters.burstLen, spikeLocs, spikePeaksValue);
        mergeType = 'first';
    end
end

