function output = reconstructFeatures(signalInfo,iter)
%reconstructFeatures Reconstruct features loaded from the created mat file
%after running mainClasifier.m
% 
% output: featuresNames, featuresAll, featuresMean, featuresStd, featuresStde
% 
%   output = reconstructFeatures()
channel = signalInfo(1,1).signal.channel;
numChannel = length(channel);
output.featuresNames = fieldnames(signalInfo(1,1).features);
output.featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(output.featuresNames);

for i = 1:iter % different speed = different class
    for j = 1:numChannel
        featuresAllTemp{i,j} = zeros(0,1);
    end
end

for i = 1:numFeatures
    for k = 1:numChannel
        for j = 1:iter % different speed = different class
            featureNameTemp = output.featuresNames{i,1};
            output.featuresAll{j,i,k} = signalInfo(j,1).features.(featureNameTemp)(:,k); % it is sorted in [bursts * classes * features * channels]
            featuresTemp = output.featuresAll{j,i,k};
            featuresAllTemp{j,k} = [featuresAllTemp{j,k},featuresTemp];
            output.featureMean(i,j,k) = nanmean(featuresTemp); % it is sorted in [features * clases * channels]
            output.featureStd(i,j,k) = nanstd(featuresTemp); % it is sorted in [features * classes * channels]
            output.featureStde(i,j,k) = output.featureStd(i,j,k) / sqrt(length(featuresTemp(~isnan(featuresTemp)))); % standard error of the feature
        end
    end
end

end

