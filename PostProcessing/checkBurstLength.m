function [newValues,newLocs] = checkBurstLength(data,windowSize,values,locs)
%checkBurstLength Trim out the starting location that doesn't have enough
%burst length for analysis
%   [newValues,newLocs] = checkBurstLength(data,windowSize,locs)

lengthData = length(data);

tempLocs = (locs + windowSize) <= lengthData;

newLocs = locs(tempLocs);
newValues = values(tempLocs);

end

