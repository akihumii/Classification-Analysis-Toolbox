function baseline = baselineDetection(data)
%baselineDetection To measure the baseline
%   baseline = bselineDetection(data)

dataSorted = sort(data,1);

numSample = length(dataSorted);

baseline = mean(dataSorted(1:floor(numSample/80))); % mean value of the samples that appears the most
end

