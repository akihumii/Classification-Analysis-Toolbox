function [startPeaks,startLocs,endPeaks,endLocs] = TKEOSpikeDetection(data,threshold,numStartConsecutivePoints,numEndConsecutivePoints)
%TKEOSpikeDetection Find the values exceeding threshold then skip for a
%window with the size of minDistance.

% numConsecutivePoint is the minimum number of the consecutive pionts
% following the peaks that need to exceed the threshold. Default value is 0.
%
%   [startPeaks,startLocs,endPeaks,endLocs] = TKEOSpikeDetection(data,threshold,minDistance,numConsecutivePoint)

if nargin < 4
    numConsecutivePoint = 0;
end

%% find the starting point of first burst
numDataPoints = length(data);
startPeaks = zeros(0,1);
startLocs = zeros(0,1);
endPeaks = zeros(0,1);
endLocs = zeros(0,1);
flag = 1; % 1: starting point, 2: end point

for i = 1 : numDataPoints-numStartConsecutivePoints
    if data(i : i+numStartConsecutivePoints) > threshold
        startPeaks = [startPeaks; data(i)];
        startLocs = [startLocs; i];
        flag = 2;
        break
    end
end

if length(startPeaks) == 0
    error('No peak is found...')
end

%% find the remaining bursts
if i < numDataPoints
    for i = i : numDataPoints-max(numStartConsecutivePoints,numEndConsecutivePoints)
        switch flag
            case 2 % get the end point of the burst
                distance = i - startLocs(end);
                if data(i : i+numEndConsecutivePoints) < threshold & ...
                        distance > numStartConsecutivePoints
                    endPeaks = [endPeaks; data(i)];
                    endLocs = [endLocs; i];
                    flag = 1;
                end
            case 1 % get the starting point of the burst
                distance = i - endLocs(end);
                if data(i : i+numStartConsecutivePoints) > threshold & ...
                        distance > numEndConsecutivePoints
                    startPeaks = [startPeaks; data(i)];
                    startLocs = [startLocs; i];
                    flag = 2;
                end
            otherwise
        end
    end
end

%% in case no end point of the last burst
if flag == 2
    endPeaks = [endPeaks;data(end)];
    endLocs = [endLocs; i];
end
end

