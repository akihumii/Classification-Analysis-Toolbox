function output = catNanMat(data,dim,type)
%catNanMat Concatenate the cells into matrix filled with NaN.
%
% input:    dim:    Currently only support 1 for vertcat and 2 for horzcat
%           type:   'all' to omit array when it fills only with Nan;
%                   'any' to omit array when it contains even one Nan.
%
%   output = catNanMat(data,dim)

output = cell2nanMat(data);

[numSamplePoints,numGroups,numChannel,numLayer] = size(output);

[~, ~, numDim] = checkSize(output);

if numDim == 3
    numChannel = 1;
end

if dim == 1
    output = reshape(output,[],numGroups,numChannel,1);
    output = omitNan(output,2,type); % delete rows that contains only Nan
elseif dim == 2
    output = reshape(output,numSamplePoints,[],numChannel,1);
    output = omitNan(output,1,type); % delete columns that contains only Nan
end

end

