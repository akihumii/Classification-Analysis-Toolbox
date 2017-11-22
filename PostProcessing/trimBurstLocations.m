function [newStartValue,newStartLocs,newEndValue,newEndLocs] = ...
    trimBurstLocations(startValue,startLocs,endValues,endLocs)
%trimBurstLocations Summary of this function goes here
%   [newStartValue,newStartLocs,newEndValue,newEndLocs] = trimBurstLocations(startValue,startLocs,endValue,endLocs)

[newEndLocs,uniqueLocs] = unique(endLocs); % get new end values and locations by finding the unique numbers
newEndValue = endValues(uniqueLocs);

numNewEndLocs = length(newEndLocs); % number of new ending locations
numStartLocs = length(startLocs); % number of original starting locations

newStartLocs = startLocs(1); % initialize the first new starting location
newStartValue = startValue(1); % initialize the first new start value

for i = 1:numNewEndLocs
    for j = 1:numStartLocs
        if startLocs(j) > newEndLocs(i)
            newStartLocs = [newStartLocs; startLocs(j)];
            newStartValue = [newStartValue; startValue(j)];
            break
        end
    end
end


end

