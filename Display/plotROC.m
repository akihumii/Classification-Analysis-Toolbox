function [] = plot2ClassROC(data,varargin)
%PLOTROC Plot ROC to show the performance of 1-d classification by
%thresholding
% input:    data:   an 1-N array of data to be classified
%   Detailed explanation goes here

data = checkSizeNTranspose(data,2);

numElement = length(data);

parameters.thresholdStepSize = numElement/100; % default step size for sweeping the threshold to classify two different class

parameters = varIntoStruct(parameters,varargin);

currentThreshold = min(data);

while currentThreshold < max(data)
    for i = 1:numElement
        
    end
    currentThreshold = currentThreshold + parameters.thresholdStepSize;
end

end

