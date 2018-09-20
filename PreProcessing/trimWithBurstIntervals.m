function output = trimWithBurstIntervals(signalInfo,numClass,burstIntervalsThreshold)
%TRIMWTIHBURSTINTERVALS Check the bursts intervals and then trim it
%accordingly
%   Detailed explanation goes here


numChannel = size(signalInfo(1,1).signal.dataRaw,2);

featureNames = fieldnames(signalInfo(1,1).signalClassification.features);
featureNames(end) = [];
numFeatures = length(featureNames);

%% get the location
for i = 1:numClass
    burstIntervalTemp = omitNan(signalInfo(i).signalClassification.burstDetection.burstIntervalSeconds,2,'all');
    for j = 1:numChannel
        burstLocs{i,j} = ...
            burstIntervalTemp(:,j) > burstIntervalsThreshold(i,1,j) &...
            burstIntervalTemp(:,j) < burstIntervalsThreshold(i,2,j);
    end
end

%% do the trimming 
for i = 1:numClass
    for j = 1:numChannel
        signalInfo(i,1).signalClassification.burstDetection.spikePeaksValue(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).signalClassification.burstDetection.spikeLocs(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).signalClassification.burstDetection.burstEndValue(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).signalClassification.burstDetection.burstEndLocs(~burstLocs{i,j},j) = nan;
        %numSelectedBurstsTemp = length(signalInfo(i,1).signalClassification.burstDetection.selectedBurstsIndex{j,1});
        %signalInfo(i,1).signalClassification.burstDetection.selectedBurstsIndex{j,1}(~burstLocs{i,j}(1:numSelectedBurstsTemp)) = [];
        
        signalInfo(i,1).signalClassification.selectedWindows.burst(:,~burstLocs{i,j},j) = nan;
        signalInfo(i,1).signalClassification.selectedWindows.burstMean = nanmean(signalInfo(i,1).signalClassification.selectedWindows.burst,2);
        signalInfo(i,1).signalClassification.selectedWindows.xAxisValues(:,~burstLocs{i,j},j) = nan;

        
        for k = 1:numFeatures
            signalInfo(i,1).signalClassification.features.(featureNames{k,1})(~burstLocs{i,j},j) = nan;
            signalInfo(i,1).features.(featureNames{k,1})(~burstLocs{i,j},j) = nan;
        end
        
        signalInfo(i,1).windowsValues.burst(:,~burstLocs{i,j},j) = nan;
        signalInfo(i,1).windowsValues.burstMean = nanmean(signalInfo(i,1).windowsValues.burst,2);
        signalInfo(i,1).windowsValues.xAxisValues(:,~burstLocs{i,j},j) = nan;
                
        signalInfo(i,1).detectionInfo.spikePeaksValue(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).detectionInfo.spikeLocs(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).detectionInfo.burstEndValue(~burstLocs{i,j},j) = nan;
        signalInfo(i,1).detectionInfo.burstEndLocs(~burstLocs{i,j},j) = nan;
        %signalInfo(i,1).detectionInfo.selectedBurstsIndex{j,1}(~burstLocs{i,j}(1:numSelectedBurstsTemp)) = [];
    end
    
    % squeeze nan and reoder
    signalInfo(i,1).signalClassification.burstDetection.spikePeaksValue = squeezeNan(signalInfo(i,1).signalClassification.burstDetection.spikePeaksValue,2);
    signalInfo(i,1).signalClassification.burstDetection.spikeLocs = squeezeNan(signalInfo(i,1).signalClassification.burstDetection.spikeLocs,2);
    signalInfo(i,1).signalClassification.burstDetection.burstEndValue = squeezeNan(signalInfo(i,1).signalClassification.burstDetection.burstEndValue,2);
    signalInfo(i,1).signalClassification.burstDetection.burstEndLocs = squeezeNan(signalInfo(i,1).signalClassification.burstDetection.burstEndLocs,2);
    
    signalInfo(i,1).signalClassification.selectedWindows.burst = squeezeNan(signalInfo(i,1).signalClassification.selectedWindows.burst,1);
    signalInfo(i,1).signalClassification.selectedWindows.xAxisValues = squeezeNan(signalInfo(i,1).signalClassification.selectedWindows.xAxisValues,1);
    
    for k = 1:numFeatures
        signalInfo(i,1).signalClassification.features.(featureNames{k,1}) = squeezeNan(signalInfo(i,1).signalClassification.features.(featureNames{k,1}),2);
        signalInfo(i,1).features.(featureNames{k,1}) = squeezeNan(signalInfo(i,1).features.(featureNames{k,1}),2);
    end
    
    signalInfo(i,1).windowsValues.burst = squeezeNan(signalInfo(i,1).windowsValues.burst,1);
    signalInfo(i,1).windowsValues.xAxisValues = squeezeNan(signalInfo(i,1).windowsValues.xAxisValues,1);
    
    signalInfo(i,1).detectionInfo.spikePeaksValue = squeezeNan(signalInfo(i,1).detectionInfo.spikePeaksValue,2);
    signalInfo(i,1).detectionInfo.spikeLocs = squeezeNan(signalInfo(i,1).detectionInfo.spikeLocs,2);
    signalInfo(i,1).detectionInfo.burstEndValue = squeezeNan(signalInfo(i,1).detectionInfo.burstEndValue,2);
    signalInfo(i,1).detectionInfo.burstEndLocs = squeezeNan(signalInfo(i,1).detectionInfo.burstEndLocs,2);
    
    for j = 1:numChannel
        numBurstsTemp(j,1) = sum(~isnan(signalInfo(i,1).detectionInfo.spikePeaksValue(:,j)));
    end
    
    signalInfo(i,1).signalClassification.selectedWindows.numBursts = numBurstsTemp;
    signalInfo(i,1).windowsValues.numBursts = numBurstsTemp;
    
end

output = signalInfo;



end

