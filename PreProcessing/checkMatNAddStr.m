function newStr = checkMatNAddStr(mat,str,varargin)
%checkMatNAddStr Check if the matrix has multiple values, add a string if
%so.
% input:    mat: could be either in cell or matrix
%           str: a string to insert in between the values
%           dim: 1 to combine the columns, 2 to combine the rows, optional,
%                default is 1.
%
%   newStr = checkMatNAddStr(mat,str)

if nargin > 2
    dim = varargin{1,1};
else
    dim = 1;
end

numPairs = size(mat,dim);

switch dim
    case 1
        numElement = size(mat,2);
    case 2
        numElement = size(mat,1);
    otherwise
        warning('Invalid dimension for adding string in between values...')
        newStr = mat;
        return
end

for i = 1:numPairs
    if iscell(mat)
        switch dim
            case 1
                newStr{i,1} = mat{i,1};
                for j = 2:numElement
                    newStr{i,1} = [newStr{i,1},str,mat{i,j}];
                end
            case 2
                newStr{i,1} = mat{1,i};
                for j = 2:numElement
                    newStr{i,1} = [newStr{i,1},str,mat{j,i}];
                end
        end
    else
        switch dim
            case 1
                newStr{i,1} = num2str(mat(i,1));
                for j = 2:numElement
                    newStr{i,1} = [newStr{i,1},str,num2str(mat(i,j))];
                end
            case 2
                newStr{i,1} = num2str(mat(1,i));
                for j = 2:numElement
                    newStr{i,1} = [newStr{i,1},str,num2str(mat(j,i))];
                end
        end
    end
end

if length(newStr) == 1
    newStr = newStr{1,1};
end
end

