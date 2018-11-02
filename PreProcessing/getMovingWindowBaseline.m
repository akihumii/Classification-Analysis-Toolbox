function burst = getMovingWindowBaseline(data,dataForThreshold,threshold,numBurst,windowSize)
%MOVINGWINDOWBASELINE Move the window to get the window of signal that does
%not contains data point exceeding threshold, it will continue until the 
%number numBurst
% input: windowSize: input desire size, otherwise input 0 for default value (300 sample points)
% 
%   Detailed explanation goes here

if windowSize == 0
    windowSize = 300;
end

%% Parameters
overlapWindowSize = 10;
windowEndPoint = windowSize;
burst = zeros(windowSize,0);
sizeData = length(data);

%% Run
while windowEndPoint <= sizeData
    windowTemp = windowEndPoint-windowSize+1:windowEndPoint;
    
    if dataForThreshold(windowTemp) < threshold
        windowEndPoint = windowEndPoint + windowSize;
        burst = [burst,data(windowTemp)];
    else
        windowEndPoint = windowEndPoint + overlapWindowSize;
    end

    if size(burst,2) == numBurst
        break
    end
end

if size(burst,2) < numBurst
    burst = [burst,nan(windowSize, numBurst-size(burst,2))];
end


end

