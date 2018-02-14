function output = pcaConverter(data)
%pcaConverter Obtain PCA of the data
% 
% output:   coeff: loadings/coefficients of each PC (variables x PC)
%           score: (sample points x PC)
%           thresholdFinal: coeff that contributes higher than 90 percentile
%           reconstructedData: using thresholdFinal for reconstruction
%           mu: mean of the variables deducted before running pca
% 
%   output = pcaConverter(data)
close all

[~,numCol] = size(data); % number of variables

mu = mean(data); % mean that will be 

[coeff,score,latent] = pca(data); % rows of coeff represent different variables, while columns corresponds to the columns of score

threshold = prctile(abs(coeff),90,2); % get the first score that exceeds 90 percentile of the entire score
thresholdRep = repmat(threshold,1,numCol); % replicate the threshold for comparison with the score matrix
thresholdLocs = coeff >= thresholdRep; % the column of score that is the threshold of 90 percentile
thresholdFinal = zeros(numCol,numCol); % initiate thresholdFinal filling with zeros
thresholdFinal(thresholdLocs) = coeff(thresholdLocs); % the number eigenvectors used for reconstruction due to higher representativeness

%% Reconstruction
reconstructedData = score * thresholdFinal'; % only use numComp principle componenets for reconstruction
reconstructedData = bsxfun(@plus, reconstructedData, mu); % add the mean back

%% Output
output.coeff= coeff; 
output.score = score; 
output.thresholdFinal = thresholdFinal; 
output.reconstructedData = reconstructedData;
output.mu = mu;
output.latent = latent;

%% plotting
% figure
% plot(data)
% title('Raw data')
% figure
% plot(reconstructedData)
% title('Reconstructed Data')
end

