function [endPointValue, endPointLocs] = findEndPoint(data, threshold, startPointLocs, numConsecutivePoint)
%findEndPoint Get the end point after the signal drops below the threshold
%for a chunk of consecutive points.
%points will not be less than minDistance.
%   [endPointValue, endPointLocs] = findEndPoint(data, threshold, startPointLocs, numConsecutivePoint)

if isnan(startPointLocs(1,1))
    endPointValue = nan;
    endPointLocs = nan;
    return
end

numsStartPointLocs = length(startPointLocs);
lengthData = length(data);

endPointValue = zeros(0,1);
endPointLocs = zeros(0,1);

for i = 1:numsStartPointLocs 
    for j = startPointLocs(i):lengthData-numConsecutivePoint
        dataTemp = data(j : (j+numConsecutivePoint));
        if  dataTemp < threshold
            endPointValue = [endPointValue; data(j)];
            endPointLocs = [endPointLocs; j];
            break
        end
    end
end

end

