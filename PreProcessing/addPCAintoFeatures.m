function output = addPCAintoFeatures(features,pcaInfo,numPrinComp)
%addPCAintoFeatures Add PCA into Features in the code analyzeFeatures.
% 
%   output = addPCAintoFeatures(featuresInfo,pcaInfo,numPrinComp)

[numFeatures, numClass, numChannel] = size(features.featureMean);

output = features;

for i = 1:numClass
    for j = 1:numChannel
        for k = 1:numPrinComp
            featureAllTemp = pcaInfo{i,j}(:,k);
            output.featuresAll{i,numFeatures+k,j} = featureAllTemp; 
            output.featureMean(numFeatures+k,i,j) = nanmean(featureAllTemp);
            output.featureStd(numFeatures+k,i,j) = nanstd(featureAllTemp);
            output.featureStde(numFeatures+k,i,j) = output.featureStd(numFeatures+k,i,j) / sqrt(length(featureAllTemp));
        end
    end
end

for i = 1:numPrinComp
    output.featuresNames = cat(1,output.featuresNames,{['PC',num2str(i)]}); % name the features as PCx, x is the index number like 1,2,3...
end


end

