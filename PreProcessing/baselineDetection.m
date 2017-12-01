function baseline = baselineDetection(data)
%baselineDetection To measure the baseline
%   baseline = bselineDetection(data)

dataSorted = sort(data,1);

numSample = length(dataSorted);

baselineArray = dataSorted(floor(numSample/4) : floor(numSample*3/4)); 
baselineMean = mean(baselineArray); % mean value of the samples that appears the most
baselineStd = std(baselineArray); % standard deviation of baseline

baseline.array = baselineArray;
baseline.mean = baselineMean;
baseline.std = baselineStd;

%% For odin Dyno
% baseline = mean(dataSorted(1:floor(numSample/80))); % mean value of the samples that appears the most

end

