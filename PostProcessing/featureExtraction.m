function output = featureExtraction(data,samplingFreq)
%featureExtraction Extract features from windows. Output = [windows * channels]
%   output = featureExtraction(data,samplingFreq)
% 
% output = maxValue, minValue, absMaxValue, areaUnderCurve, meanValue,
% sumDifferences, numZeroCrossings, numSignChanges,

[numData, numFeatures] = checkSize(data);

for i = 1:numData 
        dataRectified = abs(data(:,:,i));
    for j = 1:numFeatures 
            maxValue(j,i) = max(data(:,j,i));
            
            minValue(j,i) = min(data(:,j,i));
            
            burstLength(j,i) = (sum(~isnan(data(:,j,i))))/samplingFreq;
            if burstLength(j,i) == 0
                burstLength(j,1) = nan;
            end
            
            areaUnderCurve(j,i) = nansum(dataRectified(:,j));
            if areaUnderCurve(j,i) == 0
                areaUnderCurve(j,1) = nan;
            end
            
            meanValue(j,i) = nanmean(data(:,j,i));
            
            sumDifferences(j,i) = nansum(diff(dataRectified(:,j)));
            if sumDifferences(j,i) == 0
                sumDifferences(j,i) = nan;
            end
            
            stateZeroCrossings = diff(sign(data(:,j,i)));
            numZeroCrossings(j,i) = length(stateZeroCrossings(stateZeroCrossings~=0));
            
            stateSignChanges = diff(sign(diff(data(:,j,i))));
            numSignChanges(j,i) = length(stateSignChanges(stateSignChanges~=0));
    end
end

output.maxValue = maxValue;
output.minValue = minValue;
output.burstLength = burstLength;
output.areaUnderCurve = areaUnderCurve;
output.meanValue = meanValue;
output.sumDifferences = sumDifferences;
output.numZeroCrossings = numZeroCrossings;
output.numSignChanges = numSignChanges;

end

