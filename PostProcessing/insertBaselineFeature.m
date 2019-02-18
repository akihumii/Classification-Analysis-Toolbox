function data = insertBaselineFeature(data,baseline)
%INSERTBASELINEFEATURE Insert the baseline information into data
%   Detailed explanation goes here
[numSampleBurst, numBurst, numChannel] = size(data.selectedWindows.burst);

% if all(isnan(data.selectedWindows.burst(:,:,1:end/2)))
%     numBurst = 0;
% end

[lengthBaselineBurst, numBaselineBursts] = size(baseline.baselineBursts);

if lengthBaselineBurst > numSampleBurst
    baseline.baselineBursts(numSampleBurst+1:end, :, :) = []; % remove extra sample points in baseline bursts
else
    baselineBurstTemp = nan(size(data.selectedWindows.burst));
    baselineBurstTemp(1:lengthBaselineBurst, 1:numBurst, 1:numChannel) = baseline.baselineBursts;
    baseline.baselineBursts = baselineBurstTemp;
end

if numBaselineBursts > numBurst
    baseline.baselineBursts(:, numBurst+1:end, :) = []; % remove extra baseline windows
end

% change the data.selectedWindows
data.selectedWindows.burst = cat(3,data.selectedWindows.burst, baseline.baselineBursts);
data.selectedWindows.burstMean = nanmean(data.selectedWindows.burst,2);
data.selectedWindows.xAxisValues = repmat(data.selectedWindows.xAxisValues(:,:,1),1,1,numChannel*2);
data.selectedWindows.numBursts = cat(1,data.selectedWindows.numBursts,repmat(numBurst,numChannel,1));

% change the data.feature
featureNames = fieldnames(baseline.baselineFeature);
numFeature = length(featureNames);
for i = 1:numFeature
    data.features.(featureNames{i,1}) = cat(2,data.features.(featureNames{i,1}), baseline.baselineFeature.(featureNames{i,1}));
end

% change the grouping
trainingThreshold = floor(numBurst*data.trainingRatio); % baseline threshold
baselineClass = 100; % baseline class

featureTemp = permute(baseline.baselineFeature.(data.grouping.targetField),[1,3,2]);
data.grouping.all = cat(3,data.grouping.all,featureTemp);
data.grouping.training = data.grouping.all(1:trainingThreshold,:,:);
data.grouping.testing = data.grouping.all(trainingThreshold+1,:,:);
data.grouping.trainingClass = cat(3,data.grouping.trainingClass,repmat(baselineClass,trainingThreshold,1,numChannel));
data.grouping.testingClass = cat(3,data.grouping.testingClass,repmat(baselineClass,numBurst-trainingThreshold,1,numChannel));
data.grouping.baselineClass = baselineClass;

end

