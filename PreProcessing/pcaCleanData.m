function output = pcaCleanData(data)
%pcaCleanData Clean data by omitting principle components with too little
%latent.
%   output = pcaCleanData

% reconstruct to fit the funtion reconstructPCA
signalInfo.signalClassification.selectedWindows.burst = data;

threshPercentile = 50;

pcaInfo = reconstructPCA(signalInfo,1,threshPercentile);

numChannel = length(pcaInfo.pcaInfo);
for i = 1:numChannel
    output{i,1} = pcaInfo.pcaInfo(i,1).reconstructedData';
end

output = cell2nanMat(output); % convert into matrix

end


