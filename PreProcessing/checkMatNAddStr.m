function newStr = checkMatNAddStr(mat,str)
%checkMatNAddStr Check if the matrix has multiple values, add a string if
%so.
%   newStr = checkMatNAddStr(mat,str)

sizeMat = size(mat);

if any(sizeMat > 1)
    firstNum = num2str(mat(1));
    secondNum = num2str(mat(2));
    newStr = [firstNum,str,secondNum];
else
    newStr = num2str(mat);
end


end

