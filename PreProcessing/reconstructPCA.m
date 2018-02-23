function output = reconstructPCA(signalInfo, numclass,threshPercentile)
%reconstructPCA Reconstruct the bursts collected from analyzeFeatures and
%compute the relative PCA
%
%   output = reconstructPCA(signalInfo,iter,thresPercentile)

numChannel = size(signalInfo(1,1).signalClassification.selectedWindows.burst,3);

for i = 1:numChannel
    for j = 1:numclass
        burst{j,i} = signalInfo(j,1).signalClassification.selectedWindows.burst(:,:,i);
        burst{j,i} = omitNan(burst{j,i},1,'all');
        numBursts(j,i) = size(burst{j,i},2); % [class * channel]
    end
    
    burstPCA{i,1} = catNanMat(burst(:,i),2,'all');
    burstPCA{i,1} = omitNan(burstPCA{i,1},2,'any'); % cut the length until none of them consists of Nan
    
    pcaInfo(i,1) = pcaConverter(burstPCA{i,1}',threshPercentile); % transpose burstPCA so that the dimension is [observation * variable] = [trials * sample points]
end

% redistribute the final score into corresponding class and channel
for i = 1:numChannel
    rowIndex = 0;
    for j = 1:numclass
        rowIndex = (rowIndex(end)+1) : (sum(numBursts(1:j,i))); % index of the current array 
        scoreIndividual{j,i} = pcaInfo(i,1).scoreFinal(rowIndex,:); % separate different classes and channels into different cells
    end
end

%% Output
output.burst = burst;
output.numBursts = numBursts;
output.burstPCA = burstPCA;
output.pcaInfo = pcaInfo;
output.scoreIndividual = scoreIndividual;

end


