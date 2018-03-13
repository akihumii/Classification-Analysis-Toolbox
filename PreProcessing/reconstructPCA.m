function output = reconstructPCA(signalInfo,threshPercentile)
%reconstructPCA Reconstruct the bursts collected from analyzeFeatures and
%compute the relative PCA
%
%   output = reconstructPCA(signalInfo,threshPercentile)

numClass = length(signalInfo);
numChannel = size(signalInfo(1,1).signalClassification.selectedWindows.burst,3);
samplingFreq = signalInfo(1,1).signal.samplingFreq;

for i = 1:numChannel
    for j = 1:numClass
        burst{j,i} = signalInfo(j,1).signalClassification.selectedWindows.burst(:,:,i);
        burst{j,i} = omitNan(burst{j,i},1,'all');
        numBursts(j,i) = size(burst{j,i},2); % [class * channel]
        minBurstLength(j,i) = min(signalInfo(j,1).signalClassification.features.burstLength(:,i));
        maxBurstLength(j,i) = max(signalInfo(j,1).signalClassification.features.burstLength(:,i));  % get the maximum burst length in that class of that channel
    end
    
    burstPCARaw{i,1} = catNanMat(burst(:,i),2,'all'); % get all the bursts from different classes of one channel into a matrix
    maxBurstLocs(i,1) = floor(max(samplingFreq*maxBurstLength(:,i))); % number of sample points of the maximum bursts length in that channel
    burstPCARaw{i,1} = burstPCARaw{i,1}(1:maxBurstLocs(i,1),:); % get all the bursts with the same lengths, which is the maximum burst length of that channel in both classes
    burstPCAMean{i,1} = nanmean(abs(burstPCARaw{i,1}),2); % get the mean of all the bursts
    burstPCAMeanEnvelop{i,1} = filterData(burstPCAMean{i,1},samplingFreq,0,15,0); % apply low pass filter
    thresholdTemp = max(burstPCAMeanEnvelop{i,1}) * 0.5; % 50 percent of the envelop
    cutoffLocsTemp = burstPCAMeanEnvelop{i,1};
    cutoffLocsTemp(diff(cutoffLocsTemp)>0) = []; % omit the rising part
    cutoffLocsTemp = cutoffLocsTemp(find(cutoffLocsTemp<thresholdTemp,1));
    cutoffLocs(i,1) = find(burstPCAMeanEnvelop{i,1} == cutoffLocsTemp);
    
    burstPCA{i,1} = burstPCARaw{i,1}(1:cutoffLocs(i,1),:); % get the trimmed bursts for PCA
%     burstPCA{i,1} = omitNan(burstPCA{i,1},2,'any'); % cut the length until none of them consists of Nan
    
    pcaInfo(i,1) = pcaConverter(burstPCA{i,1}',threshPercentile); % transpose burstPCA so that the dimension is [observation * variable] = [trials * sample points]
end

% redistribute the final score into corresponding class and channel
for i = 1:numChannel
    rowIndex = 0;
    for j = 1:numClass
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


