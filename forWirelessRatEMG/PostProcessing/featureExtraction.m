function output = featureExtraction(data)
%featureExtraction Summary of this function goes here
%   Detailed explanation goes here

[rowData, colData] = size(data);

dataRectified = abs(data);

for i = 1:colData
    maxValue(1,i) = max(data(:,i));
    
    minValue(1,i) = min(data(:,i));
    
    areaUnderCurve(1,i) = sum(dataRectified(:,i));
    
    meanValue(1,i) = mean(data(:,i));
    
    sumDifferences(1,i) = sum(diff(dataRectified(:,i)));
    
    stateZeroCrossings = diff(sign(data(:,i)));
    numZeroCrossings(1,i) = length(stateZeroCrossings(stateZeroCrossings~=0));
    
    stateSignChanges = diff(sign(diff(data(:,i))));
    numSignChanges(1,i) = length(stateSignChanges(stateSignChanges~=0));
end

output.maxValue = maxValue;
output.minValue = minValue;
output.areaUnderCurve = areaUnderCurve;
output.meanValue = meanValue;
output.sumDifferences = sumDifferences;
output.numZeroCrossings = numZeroCrossings;
output.numSignChanges = numSignChanges;

end

