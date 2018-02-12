function output = catNanMat(data,dim)
%catNanMat Concatenate the cells into matrix filled with NaN.
%
% intput:   dim:    Currently only support 1 for vertcat and 2 for horzcat
%
%   output = catNanMat(data,dim)

output = cell2nanMat(data);

[numSamplePoints,numGroups,numChannel] = size(output);

[~, ~, numDim] = checkSize(output);

if numDim == 3
    numChannel = 1;
end

if dim == 1
    output = reshape(output,[],numGroups,numChannel,1);
    output = omitNan(output,2); % delete rows that contains only Nan
elseif dim == 2
    output = reshape(output,numSamplePoints,[],numChannel,1);
    output = omitNan(output,1); % delete columns that contains only Nan
end

end

