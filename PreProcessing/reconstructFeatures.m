function output = reconstructFeatures(features,numClass,numBursts)
%reconstructFeatures Reconstruct features loaded from the created mat file
%after running mainClasifier.m
%
% output: featuresNames, featuresAll, featuresMean, featuresStd, featuresStde
%
%   output = reconstructFeatures(features,numClass)

numChannel = length(features);
output.featuresNames = fieldnames(features(1,1));
numFeatures = length(output.featuresNames);

for i = 1:numFeatures
    for k = 1:numChannel
        
        arrayTemp = zeros(1,1); % initiate array for assigning features into different classes
        
        for j = 1:numClass % different speed = different class
            featureNameTemp = output.featuresNames{i,1};
            if numBursts(j,k) ~= 0 && ~isempty(features(k,1).(featureNameTemp))
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