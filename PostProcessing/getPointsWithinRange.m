function output = getPointsWithinRange(data,startLocs,endLocs,windowSize,samplingFreq)
%getPointsWithinRange Get the points within the range
%   function output = getPointsWithinRange(data,startLocs,endLocs,windowSize)

[numRow,numColumn] = size(data);

for i = 1:numColumn
    numLocs(i,1) = sum(~isnan(startLocs(:,i)));
    for j = 1:numLocs(i,1)
        burst{j,1} = data(transpose((floor(-windowSize(1)*samplingFreq)+startLocs(j,i)):endLocs(j,i)));
        xAxisValues{j,1} = transpose(1+floor(-windowSize*samplingFreq):endLocs(j,i)-startLocs(j,i)+1); % create an array of x axis values for burst plotting
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

