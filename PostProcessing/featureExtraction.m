function output = featureExtraction(data)
%featureExtraction Extract features from windows. Output = [windows * channels]
%   output = featureExtraction(data)
% 
% output = maxValue, minValue, absMaxValue, areaUnderCurve, meanValue,
% sumDifferences, numZeroCrossings, numSignChanges,

[numData, numFeatures] = checkSize(data);

for i = 1:numData 
        dataRectified = abs(data(:,:,i));
    for j = 1:numFeatures 
            maxValue(j,i) = max(data(:,j,i));
            
            minValue(j,i) = min(data(:,j,i));
            
            absMaxValue(j,i) = max(dataRectified(:,j,i));
            
            burstLength(j,i) = sum(~isnan(data(:,j,i)));
            
            areaUnderCurve(j,i) = sum(dataRectified(:,j));
            
            meanValue(j,i) = mean(data(:,j,i));
            
            sumDifferences(j,i) = sum(diff(dataRectified(:,j)));
            
            stateZeroCrossings = diff(sign(data(:,j,i)));
            numZeroCrossings(j,i) = length(stateZeroCrossings(stateZeroCrossings~=0));
            
            stateSignChanges = diff(sign(diff(data(:,j,i))));
            numSignChanges(j,i) = length(stateSignChanges(stateSignChanges~=0));
    end
end

output.maxValue = maxValue;
output.minValue = minValue;
output.absMaxValue = absMaxValue;
output.absMaxValue = absMaxValue;
output.areaUnderCurve = areaUnderCurve;
output.meanValue = meanValue;
output.sumDifferences = sumDifferences;
output.numZeroCrossings = numZeroCrossings;
output.numSignChanges = numSignChanges;

end

