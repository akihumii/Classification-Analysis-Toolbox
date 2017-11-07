function [ extractedData ] = loadData()
%LOADSYLPHX Summary of this function goes here
%   Detailed explanation goes here
[fullFileName, pathname] = uigetfile('*.csv','select excel file','MultiSelect','on');
if iscell(fullFileName)
    iter = length(fullFileName);
else
    iter = 1;
    fullFileName = cellstr(fullFileName);
end

for j = 1:iter
    name = fullFileName{j};
    disp('Loading...')
    extractedData.data = csvread([pathname name]);
end

extractedData.size = size(extractedData.data);

end