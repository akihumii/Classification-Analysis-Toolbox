function output = reconstructPCA(signalInfo,threshPercentile)
%reconstructPCA Reconstruct the bursts collected from analyzeFeatures and
%compute the relative PCA
%
%   output = reconstructPCA(signalInfo,threshPercentile)

cutoffThreshold = 0.5; % percentage to cutoff the bursts if it drops below this percentage of the maximum values

numClass = length(signalInfo);
numChannel = size(signalInfo(1,1).windowsValues.burst,3);
samplingFreq = signalInfo(1,1).signal.samplingFreq;

for i = 1:numChannel
    for j = 1:numClass
        burst{j,i} = signalInfo(j,1).windowsValues.burst(:,:,i);
        burst{j,i} = omitNan(burst{j,i},1,'all');
        numBursts(j,i) = size(burst{j,i},2); % [class * channel]
        %minBurstLength(j,i) = min(signalInfo(j,1).signalClassification.features.burstLength(:,i));
        try
            maxBurstLength(j,i) = max(signalInfo(j,1).signalClassification.features.burstLength(:,i));  % get the maximum burst length in that class of that channel
        catch
            maxBurstLength(j,i) = nan;
        end
        burstOnly{j,i} = zeros(size(burst{j,i})); % only those within the burst range will be one, the rest will be zeros
        burstLengthTemp = omitNan(signalInfo(j,1).signalClassification.features.burstLength(:,i),2,'all'); % to get the temperory burst length
        for k = 1:numBursts(j,i)
            try
                burstOnly{j,i}(1:floor(samplingFreq*burstLengthTemp(k,1)),k) = 1;
            catch
                burstOnly{j,i} = nan;
            end
        end
    end
    
    burstPCARaw{i,1} = catNanMat(burst(:,i),2,'all'); % get all the bursts from different classes of one channel into a matrix
    burstPCAOnOff{i,1} = catNanMat(burstOnly(:,i),2,'all'); % get all the bursts from different classes of one channel into a matrix (zeros and ones only)
    burstPCAOnOff{i,1}(isnan(burstPCAOnOff{i,1})) = 0; % convert Nan to 0
    maxBurstLocs(i,1) = floor(max(samplingFreq*maxBurstLength(:,i))); % number of sample points of the maximum bursts length in that channel
    try
        burstPCARaw{i,1} = burstPCARaw{i,1}(1:maxBurstLocs(i,1),:);
        burstPCAOnOff{i,1} = burstPCAOnOff{i,1}(1:maxBurstLocs(i,1),:); % get all the bursts with the same lengths, which is the maximum burst length of that channel in both classes
    catch
        burstPCARaw{i,1} = nan;
        burstPCAOnOff{i,1} = 0;
    end

    burstPCAMean{i,1} = nanmean(abs(burstPCAOnOff{i,1}),2); % get the mean of all the bursts
    thresholdTemp = max(burstPCAMean{i,1}) * cutoffThreshold; % 50 percent of the envelop
    cutoffLocsTemp = burstPCAMean{i,1};
    cutoffLocsTemp(diff(cutoffLocsTemp)>0) = []; % omit the rising part
    cutoffLocsTemp = cutoffLocsTemp(find(cutoffLocsTemp<thresholdTemp,1));
    try
        cutoffLocs(i,1) = find(burstPCAMean{i,1} < cutoffLocsTemp,1);
        burstPCA{i,1} = burstPCARaw{i,1}(1:cutoffLocs(i,1),:); % get the trimmed bursts for PCA
    catch
        cutoffLocs(i,1) = nan;
        burstPCA{i,1} = nan;
    end
    
    
    pcaInfo(i,1) = pcaConverter(burstPCA{i,1}',threshPercentile); % transpose burstPCA so that the dimension is [observation * variable] = [trials * sample points]
end

% redistribute the final score into corresponding class and channel
for i = 1:numChannel
    rowIndex = 0;
    for j = 1:numClass
        try
            rowIndex = (rowIndex(end)+1) : (sum(numBursts(1:j,i))); % index of the current array
            scoreIndividual{j,i} = pcaInfo(i,1).scoreFinal(rowIndex,:); % separate different classes and channels into different cells
        catch
            rowIndex = nan;
            scoreIndividual{j,i} = nan; % separate different classes and channels into different cells
        end
    end
end

%% Output
output = makeStruct(...
    burst,... 
    numBursts,...
    burstPCA,...
    burstPCAOnOff,...
    pcaInfo,...
    scoreIndividual,...
    cutoffLocs,...
    burstPCAMean);
end


