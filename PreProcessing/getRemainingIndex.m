function output = getRemainingIndex(maxLength, array)
%GETREMAININGINDEX Get the remaining  index other than the array
%   output = getRemainingIndex(maxLength, array)
output = find(~ismember(1:maxLength, array));
end

