function locs = getAccumulatePercentile(data,percentile)
%getAccumulatePercentile Get the location of the data where the
%accumulation exceeds certain percentile.
% 
% input:    data:   A matrix with dimension: [variables * observation]
%           percentile: The threshold
% 
% output:   locs: Location of the 90 percentile element
% 
%   locs = getAccumulatePercentile(data,percentile)

cummulativeSum = cumsum(data);

threshold = prctile(cummulativeSum,percentile);

locs = find(cummulativeSum<=threshold,1,'last');

end

