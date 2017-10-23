function [numData, numIteration] = checkSize(data)
%checkSize Check the dimension size of data and output useful info
%   [numData, numFeatures] = checkSize(data)

numData = ones(1,3); % initiate 1 by 3 array of ones
sizeData = size(data); % check the dimensions of data
numDim = length(sizeData); % check number of dimension of data
numData(1:numDim) = sizeData; % update dimension of data in numData
numIteration = numData(2); % check number of iteration in inner layer 
numData = numData(end); % check number of channels

end

