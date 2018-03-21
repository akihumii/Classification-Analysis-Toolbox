function newStr = checkMatNAddStr(mat,str)
%checkMatNAddStr Check if the matrix has multiple values, add a string if
%so.
%   newStr = checkMatNAddStr(mat,str)

sizeMat = size(mat);
numElement = sizeMat(sizeMat~=1);
if any(sizeMat > 1)
    if iscell(mat)
        newStr = mat{1};
        for i = 2:numElement
            newStr = [newStr,str,mat{i}];
        end
    else
        newStr = num2str(mat(1));
        for i = 2:numElement
            newStr = [newStr,str,num2str(mat(i))];
        end
    end
else
    newStr = num2str(mat);
end


end

