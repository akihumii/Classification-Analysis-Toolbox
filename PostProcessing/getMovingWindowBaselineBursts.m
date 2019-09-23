function [spikePeaksValue,spikeLocs,burstEndValue,burstEndLocs] = getMovingWindowBaseline(data, paramMovingWindow)
%GETMOVINGWINDOWBASELINE Get the moving window baseline by using function
%movingWindowsSpikeDetection
%   [spikePeaksValue,spikeLocs,burstEndValue,burstEndLocs] = getMovingWindowBaseline(data, paramMovingWindow)
output = movingWindowSpikeDetection(data, ...
    paramMovingWindow.lag, paramMovingWindow.threshold, paramMovingWindow.influence);

baselineFlag = ~output.signals;
% lengthBaseline = length(baselineFlag);
% baselineFlag(1:lengthBaseline/20) = 0;
% baselineFlag(lengthBaseline*19/20:end) = 0;
[~, spikeLocs] = triggerSpikeDetection(baselineFlag, 0.5, paramMovingWindow.step, paramMovingWindow.lag, 1);
spikeLocs = spikeLocs(randi([1,length(spikeLocs)], 1, length(spikeLocs)));
spikePeaksValue = data(spikeLocs);
burstEndLocs = spikeLocs + paramMovingWindow.lag;
burstEndValue = data(burstEndLocs);
end

