function locs = computeOccurence(data,dim)
%computeOccurence Comput distributions by counting the number of
%occurence of either row or column in a matrix
%
% input:    dim:    1 for checking rows, 2 for checking columns
%
% output:   locs:   The index number that is not zero
%
%   locs = computeOccurence(data,dim)

logicMatrix = data ~= 0; % number of usage of that row/columns

[numRow,numCol] = size(logicMatrix);

if dim == 1
    locs = find(logicMatrix);
    locs = mod(locs,numRow); % get number of occurences
    locs(locs==0) = numRow; % change the 0 to the last index

elseif dim == 2
    locs = find(logicMatrix');
    locs = mod(locs,numCol); % get number of occurences
    locs(locs==0) = numCol; % change the 0 to the last index

end

end

