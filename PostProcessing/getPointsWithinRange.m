function output = getPointsWithinRange(timeAxis,data,startLocs,endLocs,windowSize,samplingFreq)
%getPointsWithinRange Get the points within the range
%   function output = getPointsWithinRange(timeAxis,data,startLocs,endLocs,windowSize)

[numRow,numColumn] = size(data);

for i = 1:numColumn
    numLocs(i,1) = sum(~isnan(startLocs(:,i)));
    for j = 1:numLocs(i,1)
        burst{j,1} = data(transpose((floor(-windowSize(1)*samplingFreq)+startLocs(j,i)):endLocs(j,i)));
        xAxisValuesTemp = transpose(1+floor(-windowSize*samplingFreq):endLocs(j,i)-startLocs(j,i)+1); % create an array of x axis values for burst plotting
        % get the correct time axis
        minusLocation = 1-xAxisValuesTemp(1,1);
        timeTemp = timeAxis-timeAxis(minusLocation);
        xAxisValues{j,1} = timeTemp(1:length(xAxisValuesTemp));
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

