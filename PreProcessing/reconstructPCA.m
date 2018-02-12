function output = reconstructPCA(signalInfo, numclass)
%reconstructPCA Reconstruct the bursts collected from analyzeFeatures and
%compute the relative PCA
%
%   output = reconstructPCA(signalInfo,iter)

numChannel = size(signalInfo(1,1).signalClassification.selectedWindows.burst,3);

for i = 1:numChannel
    for j = 1:numclass
        burst{j,i} = signalInfo(j,1).signalClassification.selectedWindows.burst(:,:,i);
        burst{j,i} = omitNan(burst{j,i},1);
        numBursts(j,i) = size(burst{j,i},2); % [class * channel]
    end
    
    burstPCA{i,1} = catNanMat(burst(:,i),2);
    
    pcaInfo(i,1) = pcaConverter(burstPCA{i,1});

end

% get the number of occurences of rows ( each PC )
for i = 1:numChannel
    rowIndex = 0;
    for j = 1:numclass
        rowIndex = (rowIndex(end)+1) : (sum(numBursts(1:j,i))); % index of the current array 
        pcUsageLocs{j,i} = computeOccurence(pcaInfo(i,1).thresholdFinal(rowIndex,:),2); % compute the occurences of the principle components
    end
end

%% Output
output.burst = burst;
output.numBursts = numBursts;
output.burstPCA = burstPCA;
output.pcaInfo = pcaInfo;
output.pcUsageLocs = pcUsageLocs;

end


