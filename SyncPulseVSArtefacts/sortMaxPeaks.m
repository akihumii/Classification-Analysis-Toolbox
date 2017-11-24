function [maxPoint,maxPointPlotting,maxPointLocs,baseline] = sortMaxPeaks(locs,data)
%sortMaxPeaks Find the maximum points in between two locations
%   [maxPoint,maxPointPlotting,maxPointLocs,baseline] = sortLJ(locs,data)

numPeaks = length(locs); % number of peaks

for i = 1:numPeaks-1
    dataTemp = data(locs(i):locs(i+1)); % get data in between sync pulses
    baseline(i,1) = baselineDetection(dataTemp); % compute baseline
    [maxPointPlotting(i,1),maxPointLocsTemp] = max(dataTemp); % first maximum point to second last maximum point
    maxPointLocs(i,1) = locs(i)+maxPointLocsTemp-1;
end

i = i+1; % change i to last index
dataTemp = data(locs(i):end); % get data in between sync pulses
baseline(i,1) = baselineDetection(dataTemp); % compute baseline
[maxPointPlotting(i),maxPointLocsTemp] = max(dataTemp); % last maximum point
maxPointLocs(i,1) = locs(i)+maxPointLocsTemp-1;

% Compute Baseline
for i = 2:numPeaks
    newBaseline(i,1) = (baseline(i) + baseline(i-1))/2;
end
baseline = newBaseline;

%% minus baseline
for i = 1:numPeaks
   maxPoint(i,1) = maxPointPlotting(i,1) - baseline(i,1); % taken baseline into account
end

end

