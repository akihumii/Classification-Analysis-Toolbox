function varargout = checkSize(data)
%checkSize Check the dimension size of data, output the number of channels
% and the number of iteration in inner layer
% 
% output = [numLastDim, num2ndDim, numDim]
% 
%   [numData, numIteration, numDim] = checkSize(data)

numData = ones(1,3); % initiate 1 by 3 array of ones
sizeData = size(data); % check the dimensions of data
numDim = length(sizeData); % check number of dimension of data
numData(1:numDim) = sizeData; % update dimension of data in numData
numIteration = numData(2); % check number of iteration in inner layer
numData = numData(end); % check number of channels

if nargout >= 1
    varargout{1,1} = numData;
    if nargout >= 2
        varargout{2,1} = numIteration;
        if nargout >= 3
            varargout{3,1} = numDim;
        end
    end
end
end