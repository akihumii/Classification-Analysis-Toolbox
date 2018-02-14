function output = addPCAintoFeatures(features,pcaInfo)
%addPCAintoFeatures Add PCA into Features in the code analyzeFeatures.
% 
%   output = addPCAintoFeatures(featuresInfo,pcaInfo)

[numClass,numChannel] = size(pcaInfo);

for i = numClass
    for j = numChannel
        featureMeanTemp(i,j) = nanmean(pcaInfo{i,j});
        featureStdTemp(i,j) = nanstd(pcaInfo{i,j});
        featureStdeTemp(i,j) = featureStdTemp(i,j) / sqrt(length(pcaInfo{i,j}));
    end
end

output.featuresNames = cat(1,features.featuresNames,{'PCA'});
output.featuresAll = cat(2,features.featuresAll,reshape(pcaInfo,numClass,1,numChannel));
output.featureMean = cat(1,features.featureMean,reshape(featureMeanTemp,1,numClass,numChannel));
output.featureStd = cat(1,features.featureStd,reshape(featureStdTemp,1,numClass,numChannel));
output.featureStde = cat(1,features.featureStde,reshape(featureStdeTemp,1,numClass,numChannel));

end

