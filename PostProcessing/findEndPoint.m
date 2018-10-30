function [endPointValue, endPointLocs] = findEndPoint(data, threshold, startPointLocs, numConsecutivePoint)
%FINDENDPOINT Get the end point after the signal drops below the threshold
%for a chunk of consecutive points. Points will not be less than minDistance.
% 
% input: startPointLocs: If startPointLocs is 0, then it will find only one
% endpoint if it exists
% 
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

if startPointLocs ~= 0
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
else
    for i = lengthData-numConsecutivePoint : -1 : 1
        dataTemp = data(i : (i+numConsecutivePoint));
        if dataTemp < threshold
            endPointValue = [endPointValue; data(i)];
            endPointLocs = [endPointLocs; i];
        end
    end
end

end

