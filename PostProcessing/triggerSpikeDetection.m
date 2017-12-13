function [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance,numConsecutivePoint)
%triggerSpikeDetection Find the values exceeding threshold then skip for a
%window with the size of minDistance. Distance between two consecutive
%starting points will not less than minDistance.
% 
% numConsecutivePoint is the minimum number of the consecutive pionts 
% following the peaks that need to exceed the threshold. Default value is 0.
% 
%   [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance,numConsecutivePoint)

if nargin < 4
    numConsecutivePoint = 0;
end

%% find the first peak
numDataPoints = length(data);
selectedPeaks = zeros(0,1);
selectedLocs = zeros(0,1);

for i = 1:numDataPoints-numConsecutivePoint
    if data(i : i+numConsecutivePoint) > threshold
        selectedPeaks = [selectedPeaks; data(i)];
        selectedLocs = [selectedLocs; i];
        break
    end
end

if isempty(selectedPeaks)
    error('No peak is found...')
end

%% find the remaining peaks
if i < numDataPoints
    for i = 2:numDataPoints-numConsecutivePoint
        distance = i - selectedLocs(end);
        if data(i : i+numConsecutivePoint) > threshold & ...
                distance > minDistance
            selectedPeaks = [selectedPeaks; data(i)];
            selectedLocs = [selectedLocs; i];
        end
    end
end
end

