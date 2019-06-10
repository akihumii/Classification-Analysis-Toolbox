function [chStartingPoint, chEndPoint] = getStartEndLocs(dataRef, targetAddress)
%GETSTARTENDLOCS Get starting and end points in generateSquarePulse
%   Detailed explanation goes here

% starting point locs
preLocs = find(dataRef(:,1) == targetAddress);  % find starting point of stimulation for electrodes channels in channel 13
preLocsDiff = diff(preLocs);
if ~isempty(preLocsDiff)
    chLocs = preLocs([true;preLocsDiff~=1]);
else
    warning(sprintf('Couldn''t find %d...', targetAddress));
    chLocs = [];
end
locsTemp = find(dataRef(chLocs,2) ~= 0);
chStartingPoint = chLocs(locsTemp);

% end point locs
locsEndTemp = locsTemp + 1;
lenLocsTemp = length(chLocs);
if any(locsEndTemp > lenLocsTemp)
    chEndPoint = chLocs(locsEndTemp <= lenLocsTemp);
    chEndPoint = [chEndPoint; repmat(size(dataRef,1), sum(locsEndTemp > lenLocsTemp),1)];
else
    chEndPoint = chLocs(locsEndTemp);
end

end

