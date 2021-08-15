function [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = ...
    editBurstLen(data, burstLen, spikeLocs, spikePeaksValue)
%EDITBURSTLEN Edit the burstEndLocs to the point where the fix window size
%applies.
% 
%   [spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue] = editBurstLen(data, burstLen, spikeLocs, spikePeaksValue, burstEndLocs, burstEndValue)

dataCol = size(data,2);

burstEndLocs = spikeLocs + burstLen;

dataSize = size(data,1);
burstEndLocsFlag = burstEndLocs > dataSize;
burstEndLocs(burstEndLocsFlag) = nan;
rowToBeDeleted = all(isnan(burstEndLocs),2);
burstEndLocs(rowToBeDeleted,:) =  [];

if ~isempty(burstEndLocs)
    for i = 1:dataCol
        burstEndValueTemp{i,1} = data(burstEndLocs(~isnan(burstEndLocs(:,i)),i));
    end
    
    burstEndValue = cell2nanMat(burstEndValueTemp);
else
    burstEndValue = [];
end


% omit burst that exceeds the end of data
spikeLocs(rowToBeDeleted,:) = [];
spikePeaksValue(rowToBeDeleted,:) = [];

end

