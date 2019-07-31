function [output, index] = equalizeData(data)
%EQUALIZEDATA Get the equalize number of data and the locations.
% output: index: sepearted in different cells for different classes
%   [output, index] = equalizeData(data)
data = checkSizeNTranspose(data, 2);
uniqueData = unique(data);
lenUniqueData = length(uniqueData);
for i = 1:lenUniqueData
    index{i,1} = find(data == uniqueData(i));
    lenData(i,1) = length(index{i,1});
end
minimumLength = min(lenData);
output = [];
for i = 1:lenUniqueData
    index{i,1} = index{i,1}(randperm(length(index{i,1}),minimumLength));
    output = [output; data(index{i,1})];
end

