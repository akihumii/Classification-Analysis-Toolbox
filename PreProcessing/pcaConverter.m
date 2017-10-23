function output = pcaConverter(data)
%pcaConverter Obtain PCA of the data
%   output = pcaConverter(data)

[COEFF,SCORE,latent,tsquare] = princomp(data);

output.coeff = COEFF; % loadings/coefficients of each PC (observation x variables)
output.score = SCORE; % representaion of X in PC space (observation x components)
output.latent = latent; % eigenvalues of covariance matrix of X (variance of columns of SCORE)
output.tsquare = tsquare; % Hotelling's T^2 statistic for each data point (multivariate distance of each observation from centre of data set)

end

