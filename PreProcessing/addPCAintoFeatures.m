function output = addPCAintoFeatures(features,pcaInfo)
%addPCAintoFeatures Add PCA into Features in the code analyzeFeatures.
% 
%   output = addPCAintoFeatures(featuresInfo,pcaInfo)

output = features; % initiate output

numRow = size(output.featuresAll,1);

output.featuresNames = 'PCA';
output.featuresAll = cat(2,output.featuresAll,reshape(pcaInfo,numRow,1,[]));

end

