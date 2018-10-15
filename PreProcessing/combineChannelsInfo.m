function signalInfo = combineChannelsInfo(signalInfo)
%COMBINECHANNELINFO Combine the channels info like features etc to do an
%overall classification
%   Detailed explanation goes here

featureNames = fieldnames(signalInfo(1,1).signalClassification.features);
featureNames(end) = [];
numFeatures = length(featureNames);

numClass = length(signalInfo);

for i = 1:numClass
    numBurstSelectedWindows = size(signalInfo(i,1).signalClassification.selectedWindows.burst,2);
    numBurstWindowValues = size(signalInfo(i,1).windowsValues.burst,2);

    signalInfo(i,1).signalClassification.burstDetection.spikePeaksValue = signalInfo(i,1).signalClassification.burstDetection.spikePeaksValue(:);
    signalInfo(i,1).signalClassification.burstDetection.spikeLocs = signalInfo(i,1).signalClassification.burstDetection.spikeLocs(:);
    signalInfo(i,1).signalClassification.burstDetection.burstEndValue = signalInfo(i,1).signalClassification.burstDetection.burstEndValue(:);
    signalInfo(i,1).signalClassification.burstDetection.burstEndLocs = signalInfo(i,1).signalClassification.burstDetection.burstEndLocs(:);
    signalInfo(i,1).signalClassification.burstDetection.selectedBurstsIndex{i,1} = signalInfo(i,1).signalClassification.burstDetection.selectedBurstsIndex{i,1}(:);
    
    signalInfo(i,1).signalClassification.selectedWindows.burst = signalInfo(i,1).signalClassification.selectedWindows.burst(:,:);
    signalInfo(i,1).signalClassification.selectedWindows.burstMean = mean(signalInfo(i,1).signalClassification.selectedWindows.burst,2);
    signalInfo(i,1).signalClassification.selectedWindows.xAxisValues = signalInfo(i,1).signalClassification.selectedWindows.xAxisValues(:,:);
    signalInfo(i,1).signalClassification.selectedWindows.numBursts = sum(signalInfo(i,1).signalClassification.selectedWindows.numBursts);
    
    for j = 1:numFeatures
        signalInfo(i,1).signalClassification.features.(featureNames{j,1}) = signalInfo(i,1).signalClassification.features.(featureNames{j,1});
    end
    
    signalInfo(i,1).signalClassification.grouping.all = signalInfo(i,1).signalClassification.grouping.all(:);
    
    signalInfo(i,1).windowsValues.burst = signalInfo(i,1).windowsValues.burst(:,:);
    signalInfo(i,1).windowsValues.burstMean = mean(signalInfo(i,1).windowsValues.burst,2);
    signalInfo(i,1).windowsValues.xAxisValues = signalInfo(i,1).windowsValues.xAxisValues(:,:);
    signalInfo(i,1).windowsValues.numBursts = sum(signalInfo(i,1).windowsValues.numBursts);
    
    for j = 1:numFeatures
        signalInfo(i,1).features.(featureNames{j,1}) = signalInfo(i,1).features.(featureNames{j,1})(:);
    end
    
    signalInfo(i,1).detectionInfo.spikePeaksValue = signalInfo(i,1).detectionInfo.spikePeaksValue(:);
    signalInfo(i,1).detectionInfo.spikeLocs = signalInfo(i,1).detectionInfo.spikeLocs(:);
    signalInfo(i,1).detectionInfo.burstEndValue = signalInfo(i,1).detectionInfo.burstEndValue(:);
    signalInfo(i,1).detectionInfo.burstEndLocs = signalInfo(i,1).detectionInfo.burstEndLocs(:);
    signalInfo(i,1).detectionInfo.selectedBurstsIndex{i,1} = signalInfo(i,1).detectionInfo.selectedBurstsIndex{i,1}(:);
end

end

