function features = combineBaseline(signalInfo,features)
%COMBINEBASELINE Combine the baseline from different classes
%   features = combineBaseline(signalInfo,features)

[~,numBurst,numChannel] = size(signalInfo(1,1).signalClassification.selectedWindows.burst); % the numChannel here includes the baseline channels

fieldNames = fieldnames(features);
numFeature = length(fieldNames);

% randomly select baseline bursts
for i = numChannel/2+1 : numChannel
    numBaselineBurst = length(features(i,1).maxValue);
    channelSelected = transpose(randperm(numBaselineBurst));
    channelSelected = channelSelected(1:numBurst,1);
    for j = 1:numFeature
        features(i,1).(fieldNames{j,1}) = features(i,1).(fieldNames{j,1})(channelSelected);
    end
end

% append baseline bursts into EMG bursts in separate channels
for i = 1:numChannel/2
    for j = 1:numFeature
        features(i,1).(fieldNames{j,1}) = [features(i,1).(fieldNames{j,1}); ...
            features(i+numChannel/2).(fieldNames{j,1})];
    end
end

% delete the baseline channels
features(numChannel/2 + 1 : end) = [];

% signalInfo(1,1).signalClassification.selectedWindows.burst = cat(3,signalInfo(1,1).signalClassification.selectedWindows.burst(:,:,numChannel/2)),signalInfo(1,1).signalClassification.selectedWindows.burst

end

