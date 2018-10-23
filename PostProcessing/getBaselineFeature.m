function output = getBaselineFeature(data,samplingFreq)
%GETBASELINEFEATURE Get the baseline feature by using the baseline defined
%earlier
%   output = getBaselineFeature(data,samplingFreq)

numChannel = length(data.baseline);
numBurst = size(data.spikePeaksValue,1);

for i = 1:numChannel
    baselineBursts{i,1} = data.baseline{i,1}.array;
    numSample = length(baselineBursts{i,1});
    
    % trim the baseline to make it divisible by numBurst
    numNice = floor(numSample/numBurst) * numBurst;
    baselineBursts{i,1} = baselineBursts{i,1}(1:numNice);
    % baselineLocsTemp = 1:numNice;
    
    baselineBursts{i,1} = reshape(baselineBursts{i,1},[],numBurst);
    % baselineLocsTemp = reshape(baselineLocsTemp,[],numBurst);
end

baselineBursts = cell2nanMat(baselineBursts);

baselineFeature = featureExtraction(baselineBursts,samplingFreq);

%% output
output = makeStruct(...
    baselineBursts,...
    baselineFeature);


end

