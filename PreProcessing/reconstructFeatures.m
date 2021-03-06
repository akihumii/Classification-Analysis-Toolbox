function output = reconstructFeatures(signalInfo,features,numClass,numChannel,numBursts,getBasleineFeatureFlag)
%reconstructFeatures Reconstruct features loaded from the created mat file
%after running mainClasifier.m.
% The original structure is [channel x 1] structure storing vertically
% concatenated bursts from all the classes.
%
% output: featuresNames, featuresAll, featuresMean, featuresStd, featuresStde
%
%   output = reconstructFeatures(features,numClass)

% Combine the baseline channels if the option is enabled
if getBasleineFeatureFlag
    features = combineBaseline(signalInfo,features); % append the baseline features onto EMG bursts features
    numBursts = [numBursts ; max(numBursts,[],1)]; % added one more row for the baseline bursts
    numClass = numClass + 1; % added one more class for the baseline
else
    features = features(1:numChannel,1);
end

output.featuresNames = fieldnames(features(1,1));
numFeatures = length(output.featuresNames);

for i = 1:numFeatures
    for k = 1:numChannel
        
        arrayTemp = zeros(1,1); % initiate array for assigning features into different classes
        
        for j = 1:numClass % different speed = different class
            featureNameTemp = output.featuresNames{i,1};
            if numBursts(j,k) ~= 0 && length(features(k,1).(featureNameTemp)) >= numBursts(j,k)
                arrayTemp = arrayTemp(end)+1 : (arrayTemp(end) + numBursts(j,k));
                output.featuresAll{j,i,k} = features(k,1).(featureNameTemp)(arrayTemp,:); % it is sorted in [bursts * classes * features * channels]
                featuresTemp = output.featuresAll{j,i,k};
                output.featureMean(i,j,k) = nanmean(featuresTemp); % it is sorted in [features * clases * channels]
                output.featureStd(i,j,k) = nanstd(featuresTemp); % it is sorted in [features * classes * channels]
                output.featureStde(i,j,k) = output.featureStd(i,j,k) / sqrt(length(featuresTemp(~isnan(featuresTemp)))); % standard error of the feature
            else
                output.featuresAll{j,i,k} = nan; % it is sorted in [bursts * classes * features * channels]
                output.featureMean(i,j,k) = nan; % it is sorted in [features * clases * channels]
                output.featureStd(i,j,k) = nan; % it is sorted in [features * classes * channels]
                output.featureStde(i,j,k) = nan; % standard error of the feature
            end
        end
    end
end

end