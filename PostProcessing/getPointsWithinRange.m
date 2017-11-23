function output = getPointsWithinRange(data,startLocs,endLocs)
%getPointsWithinRange Get the points within the range
%   Detailed explanation goes here

[numRow,numColumn] = size(data);

for i = 1:numColumn
    numLocs(i,1) = length(~isnan(startLocs(:,i)));
    for j = 1:numLocs
        burst{j,1} = data(transpose(startLocs(j,i):endLocs(j,i)));
        xAxisValues{j,1} = transpose(1:(endLocs(j,i)-startLocs(j,i)+1)); % create an array of x axis values for burst plotting
    end
    burstAll{i,1} = cell2nanMat(burst);
    xAxisValuesAll{i,1} = cell2nanMat(xAxisValues);
end

burstAll = cell2nanMat(burstAll);
xAxisValuesAll = cell2nanMat(xAxisValuesAll);

output.burst = burstAll;
output.xAxisValues = xAxisValuesAll;
output.numBursts = numLocs;
end

