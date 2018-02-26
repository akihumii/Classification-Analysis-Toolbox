function output = catNanMat(data,dim,type)
%catNanMat Concatenate the cells into matrix filled with NaN. The values in
%the same level will be put together in the same dimension.
% Eg. While combining 2 cells consisting of 3-D matrix, the 3-D matrix in
% the first 4-D dimension will consist of the first 2-D layers of both cells
%
% input:    dim:    Currently only support 1 for vertcat and 2 for horzcat
%           type:   'all' to omit array when it fills only with Nan;
%                   'any' to omit array when it contains even one Nan.
%
%   output = catNanMat(data,dim,type)

if ~isempty(data{1,1}) % run only when it's not empty cell
    output = cell2nanMat(data);
    
    [numSamplePoints,numGroups,numClass,numChannel] = size(output);
    
    [~, ~, numDim] = checkSize(output);
    
    if numDim == 3
        numClass = 1;
    end
    
    output = permute(output,[1,2,4,3]); % Swap 2nd 2-D matrix of the first 4th dimension with the 1st 2-D matrix of the 2nd 4th dimension
    
    if dim == 1
        output = reshape(output,[],numGroups,numClass,1);
        output = omitNan(output,2,type); % delete rows that contains only Nan
    elseif dim == 2
        output = reshape(output,numSamplePoints,[],numClass,1);
        output = omitNan(output,1,type); % delete columns that contains only Nan
    end
else
    output = nan;
end

end

