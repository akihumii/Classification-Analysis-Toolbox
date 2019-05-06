function output = mat2tallCell(data)
%MAT2TALLCELL Convert the matrix data into one column of cells, split the
%columns in matrix data into different cells
%   output = mat2tallCell(data)
output = mat2cell(data, size(data, 1), ones(1, size(data,2)))';
end

