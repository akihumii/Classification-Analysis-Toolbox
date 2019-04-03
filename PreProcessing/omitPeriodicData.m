function output = omitPeriodicData(data, windowSize, period, startingPoint)
%OMITPERIODICDATA Omit the data chunks periodically
%   output = omitPeriodicData(data, windowSize, period, startingPoint)

windowPoints = getWindowPoints(size(data,1), windowSize, period, startingPoint);

data(windowPoints,:) = [];

output = data;
end

function output = getWindowPoints(lengthData, windowSize, period, startingPoint)
startingPointAll = startingPoint : period : lengthData;  % get all the starting points

output = zeros(1,0);
for i = 1:length(startingPointAll)
    output = horzcat(output, startingPointAll(i):startingPointAll(i)+windowSize-1);  % get all the samples in the window size starting from the starting points
end

output(output > lengthData) = [];  % omit the data points that exceed data length
end

