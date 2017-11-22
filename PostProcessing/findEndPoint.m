function [endPointValue, endPointLocs] = findEndPoint(data, threshold, startPointLocs, numConsecutivePoint)
%findEndPoint Summary of this function goes here
%   Detailed explanation goes here

numsStartPointLocs = length(startPointLocs);
lengthData = length(data);

endPointValue = zeros(0,1);
endPointLocs = zeros(0,1);

for i = 1:numsStartPointLocs 
    for j = startPointLocs(i):lengthData-numConsecutivePoint
        if data(j : (j+numConsecutivePoint)) < threshold
            endPointValue = [endPointValue; data(j)];
            endPointLocs = [endPointLocs; j];
            break
        end
    end
end

end

