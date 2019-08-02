function output = featureExtraction(data,samplingFreq,varargin)
%featureExtraction Extract features from windows. Output = [windows * channels]
%   input: varargin: index number of feature to extract
%   output = featureExtraction(data,samplingFreq)
% 
% output = maxValue, minValue, absMaxValue, areaUnderCurve, meanValue,
% sumDifferences, numZeroCrossings, numSignChanges,
% 
%       output = featureExtraction(data,samplingFreq,varargin)

featureNames = {...
    'maxValue';...
    'minValue';...
    'burstLength';...
    'areaUnderCurve';...
    'meanValue';...
    'sumDifferences';...
    'numZeroCrossings';...
    'numSignChanges'};

numFeature = length(featureNames);

if nargin > 2
    runTable = zeros(numFeature,1);
    runTable(varargin{1,1},1) = 1;
else
    runTable = ones(numFeature,1);
end
    
[numData, numFeatures] = checkSize(data);

for i = 1:numData 
        dataRectified = abs(data(:,:,i));
    for j = 1:numFeatures 
        if runTable(1,1)
            output.maxValue(j,i) = max(data(:,j,i));
        end
        
        if runTable(2,1)
            output.minValue(j,i) = min(data(:,j,i));
        end
        
        if runTable(3,1)
            output.burstLength(j,i) = (sum(~isnan(data(:,j,i))))/samplingFreq;
            if output.burstLength(j,i) == 0
                output.burstLength(j,i) = nan;
            end
        end
        
        if runTable(4,1)
            output.areaUnderCurve(j,i) = nansum(dataRectified(:,j));
            if output.areaUnderCurve(j,i) == 0
                output.areaUnderCurve(j,i) = nan;
            end
        end
        
        if runTable(5,1)
            output.meanValue(j,i) = nanmean(dataRectified(:,j));
        end
        
        if runTable(6,1)
            output.sumDifferences(j,i) = nansum(diff(dataRectified(:,j)));
            if output.sumDifferences(j,i) == 0
                output.sumDifferences(j,i) = nan;
            end
        end
        
        if runTable(7,1)
            stateZeroCrossings = diff(sign(data(:,j,i)));
            output.numZeroCrossings(j,i) = length(stateZeroCrossings(stateZeroCrossings~=0 & ~isnan(stateZeroCrossings)));
        end
        
        if runTable(8,1)
            stateSignChanges = diff(sign(diff(data(:,j,i))));
            output.numSignChanges(j,i) = length(stateSignChanges(stateSignChanges~=0 & ~isnan(stateSignChanges)));
        end
    end
end

end

