function [endPointValue, endPointLocs] = findEndPoint(data, threshold, startPointLocs, numConsecutivePoint)
%findEndPoint Summary of this function goes here
%   Detailed explanation goes here

numsStartPointLocs = length(startPointLocs);
lengthData = length(data);

endPointValue = zeros(0,1);
endPointLocs = zeros(0,1);

for i = 1:numsStartPointLocs 
    for j = startPointLocs(i):lengthData
        if data((startPointLocs(i)+j) : (startPointLocs(i)+j+numConsecutivePoint)) < threshold
            endPointValue = [endPointValue; data(startPointLocs(i)+j)];
            endPointLocs = [endPointLocs; (startPointLocs(i)+j)];
            break
        end
    end
end

end

