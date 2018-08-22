function [] = getVariableNames(data)
%GETVARIABLENAMES Use the function assignin to get the names in the cells.
%   Detailed explanation goes here

data = checkSizeNTranspose(data,2);

numNames = length(data);

for i = 1:numNames
    assignin('caller','data{i,1}',data{i,1})
end

end

