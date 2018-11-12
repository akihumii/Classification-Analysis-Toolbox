function baseline = baselineDetection(data)
%baselineDetection To measure the baseline
%   baseline = bselineDetection(data)
% 
% output = array, mean, std

lowCutoff = 0.3;
highCutoff = 0.7;

dataSorted = sort(data(data~=0),1);

numSample = length(dataSorted);

baselineArray = dataSorted(floor(numSample * lowCutoff) : floor(numSample * highCutoff)); % get the middle part
baselineMean = mean(baselineArray); % mean value of the samples that appears the most
baselineStd = std(baselineArray); % standard deviation of baseline

baseline.array = baselineArray;
baseline.mean = baselineMean;
baseline.std = baselineStd;

%% For odin Dyno
% baseline = mean(dataSorted(1:floor(numSample/80))); % mean value of the samples that appears the most

end

