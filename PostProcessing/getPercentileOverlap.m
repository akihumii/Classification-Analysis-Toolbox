function output = getPercentileOverlap(overlapPerc,data,numData)
%GETPERCENTILEOVERLAP Get the threshold of the data where the percentile is
%not overlapping.
% input:    overlapPerc:    The percentile of the set data that is used for checking the overlapping.
% output:   sorted data grouped with columns, rows represent the range of each group
% 
%   output = getPercentileOverlap(overlapPerc,data,numData)

for i = 1:numData
    extremePoint(i,:) = prctile(data{i,1},overlapPerc);
end

extremePointSorted = sort(extremePoint(:));

output = reshape(extremePointSorted,[],2);

end

