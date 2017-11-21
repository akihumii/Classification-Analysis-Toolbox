function [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance)
%triggerSpikeDetection Find the values exceeding threshold then skip for a
%window with the size of minDistance.
%   [selectedPeaks,selectedLocs] = triggerSpikeDetection(data,threshold,minDistance)

[values, locs] = findpeaks(data,'minPeakHeight',threshold);

numPeaks = length(locs);
selectedPeaks = values(1);
selectedLocs = locs(1);

for i = 2:numPeaks
    distance = locs(i) - selectedLocs(end);
    if distance > minDistance
        selectedPeaks = [selectedPeaks; values(i)];
        selectedLocs = [selectedLocs; locs(i)];
    end
end

if length(selectedPeaks) == 1
    error('Error found in User Input: threshold is too high')
end
end

