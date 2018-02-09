function output = pcaConverter(data)
%pcaConverter Obtain PCA of the data
% 
% output:   coeff, score, latent, tsquare
% 
%   output = pcaConverter(data)
close all

[numRow,numCol] = size(data); % number of variables

thresholdFinal = 1; % number of eigenvectors used for reconstruction
mu = mean(data); % mean that will be 

[coeff,score] = pca(data); % rows of coeff represent different variables, while columns corresponds to the columns of score

threshold = prctile(abs(coeff),90,2); % get the first score that exceeds 90 percentile of the entire score
thresholdRep = repmat(threshold,1,numCol); % replicate the threshold for comparison with the score matrix
thresholdLocs = coeff >= thresholdRep; % the column of score that is the threshold of 90 percentile
thresholdFinal = zeros(numCol,numCol); % initiate thresholdFinal filling with zeros
thresholdFinal(thresholdLocs) = coeff(thresholdLocs); % the number eigenvectors used for reconstruction due to higher representativeness

reconstructedData = score * thresholdFinal'; % only use numComp principle componenets for reconstruction
reconstructedData = bsxfun(@plus, reconstructedData, mu); % add the mean back

%% Output
output.coeff= coeff; % loadings/coefficients of each PC (observation x variables)
output.score = score; % representaion of X in PC space (observation x components)
output.thresholdFinal = thresholdFinal;
output.reconstructedData = reconstructedData;

%% plotting
figure
plot(data)
title('Raw data')
figure
plot(reconstructedData)
title('Reconstructed Data')
end

