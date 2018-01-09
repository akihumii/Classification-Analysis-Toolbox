function newMat = checkSizeNTranspose(mat,type)
%checkSizeNTrnaspose Check the size of the matrix, then transpose it if it
%is not the specified type. Do nothing if none of its dimension is 1.
%
% input: type: 1 for generting horizontal matrix, 2 for generating vertical matrix
%
%   newMat = checkSizeNTranspose(mat,type)

sizeMat = size(mat);

try
    if any(sizeMat==1) % proceed if one of its dimension is 1
        if size(mat,type) ~= 1 % transpose it if the specified dimension is not 1
            newMat = transpose(mat);
        elseif size(mat,type) == 1 % if it is already in the correct shape
            newMat = mat;
        end
    else
        newMat = mat;
    end
catch
    warning('No matrix type is input in checkSizeNTrnaspose function...')
    newMat = mat;
end

end

