function output = squeezeNan(data,dim)
%SQUEEZENAN Squeeze out the NaN in between the values, but retain the size
%of the data.
% input:    dim: 1: Squeeze NaN in the rows
%                2: Squeeze NaN in the columns.
%   output = squeezeNan(data,dim)

[numData,~,numDim] = checkSize(data);
numDimArray = 1:numDim;

if dim == 1
    numDimArrayTemp = numDimArray;
    numDimArrayTemp([1,2]) = numDimArrayTemp([2,1]);
    data = permute(data,numDimArrayTemp);
end

numColumn = size(data,2);

for i = 1:numData
    if dim ~= 1 && dim ~= 2
        warning('Invalid dim, return matrix without squeezing Nan...')
        outputTemp = data;
    else
        for j = 1:numColumn
            outputTemp{j,i} = data(~isnan(data(:,j,i)),j,i);
        end
        output{i,1} = cell2nanMat(outputTemp(:,i));
        if dim == 1
            output{i,1} = permute(output{i,1},numDimArrayTemp);
        end
    end
end

output = cell2nanMat(output);

% if dim == 2 && size(output,2) == 1
%     output = checkSizeNTranspose(output,1);
% end
% output = vertcat(output{:,1});

% if dim == 1
%     output = permute(output,numDimArrayTemp);
% end

end

