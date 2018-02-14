function output = reconstructPCA(signalInfo, numclass)
%reconstructPCA Reconstruct the bursts collected from analyzeFeatures and
%compute the relative PCA
%
%   output = reconstructPCA(signalInfo,iter)

numChannel = size(signalInfo(1,1).signalClassification.selectedWindows.burst,3);

for i = 1:numChannel
    for j = 1:numclass
        burst{j,i} = signalInfo(j,1).signalClassification.selectedWindows.burst(:,:,i);
        burst{j,i} = omitNan(burst{j,i},1,'all');
        numBursts(j,i) = size(burst{j,i},2); % [class * channel]
    end
    
    burstPCA{i,1} = catNanMat(burst(:,i),2,'all');
    burstPCA{i,1} = omitNan(burstPCA{i,1},2,'any'); % cut the length until none of them consists of Nan
    
    pcaInfo(i,1) = pcaConverter(burstPCA{i,1}'); % transpose burstPCA so that the dimension is [observation * variable] = [trials * sample points]
end

% redistribute the final score into corresponding class and channel
for i = 1:numChannel
    rowIndex = 0;
    for j = 1:numclass
        rowIndex = (rowIndex(end)+1) : (sum(numBursts(1:j,i))); % index of the current array 
        scoreIndividual{j,i} = pcaInfo(i,1).scoreFinal(rowIndex,:); % compute the occurences of the principle components
    end
end

%% Output
output.burst = burst;
output.numBursts = numBursts;
output.burstPCA = burstPCA;
output.pcaInfo = pcaInfo;
output.scoreIndividual = scoreIndividual;

end


