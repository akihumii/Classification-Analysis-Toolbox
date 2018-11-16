function output = pcaConverter(data,threshPercentile)
%pcaConverter Obtain PCA of the data
% 
% output:   coeff: loadings/coefficients of each PC (variables x PC)
%           score: (sample points x PC)
%           thresholdFinal: coeff that contributes higher than 90 percentile
%           reconstructedData: using thresholdFinal for reconstruction
%           mu: mean of the variables deducted before running pca
% 
%   output = pcaConverter(data,threshPercentile)
% close all

% [~,numCol] = size(data); % number of variables

mu = mean(data); % mean that will be deducted at the begining of function pca

[coeff,score,latent] = pca(data); % rows of coeff represent different variables, while columns corresponds to the columns of score

latentThreshLocs = getAccumulatePercentile(latent,threshPercentile); % use 90 percentile of the latent (eigenvalues) to represent the observations

scoreFinal = score(:,1:latentThreshLocs);
coeffFinal = coeff(:,1:latentThreshLocs);

%% Reconstruction
reconstructedData = scoreFinal * coeffFinal'; % only use numComp principle componenets for reconstruction
reconstructedData = bsxfun(@plus, reconstructedData, mu); % add the mean back

%% Output
output.coeff= coeff; 
output.score = score; 
output.latent = latent;
output.coeffFinal = coeffFinal; 
output.scoreFinal = scoreFinal;
output.reconstructedData = reconstructedData;
output.mu = mu;
output.rawData = data;

end

