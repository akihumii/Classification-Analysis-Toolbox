function [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance,numConsecutivePoint)
%triggerSpikeDetection Find the values exceeding threshold then skip for a
%window with the size of minDistance. 

% numConsecutivePoint is the minimum number of the consecutive pionts 
% following the peaks that need to exceed the threshold. Default value is 0.
% 
%   [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance,numConsecutivePoint)

if nargin < 4
    numConsecutivePoint = 0;
end

%% find the first peak
[values, locs] = findpeaks(data,'minPeakHeight',threshold);

numPeaks = length(locs);
selectedPeaks = zeros(0,1);
selectedLocs = zeros(0,1);

for i = 1:numPeaks
    if data(locs(i) : locs(i)+numConsecutivePoint) > threshold
        selectedPeaks = [selectedPeaks; values(i)];
        selectedLocs = [selectedLocs; locs(i)];
        break
    end
end

if length(selectedPeaks) == 0
    error('No peak is found...')
end

%% find the remaining peaks
if i < numPeaks
    for i = 2:numPeaks
        distance = locs(i) - selectedLocs(end);
        if data(locs(i) : locs(i)+numConsecutivePoint) > threshold & ...
                distance > minDistance
            selectedPeaks = [selectedPeaks; values(i)];
            selectedLocs = [selectedLocs; locs(i)];
        end
    end
end
end

