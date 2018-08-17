function output = balanceBursts(signalInfo,numClass)
%BALANCEBURSTS Balance the number of bursts from different classes in the
%same channel.
%
%   Detailed explanation goes here

trainingRatio = 0.7;

numBurstsAll = zeros(0,0);
for i = 1:numClass
    numBurstsAll = vertcat(numBurstsAll,transpose(signalInfo(i,1).signalClassification.selectedWindows.numBursts));
    signalInfo(i,1).signalClassification.trainingRatio = trainingRatio;
end

[numBurstsMin, ~] = min(numBurstsAll,[],1);
[~, numBurstsMaxChannel] = max(numBurstsAll,[],1);

numChannel = length(numBurstsMin);

featureNames = fieldnames(signalInfo(1,1).signalClassification.features);
featureNames(end) = [];
numFeatures = length(featureNames);

featureNamesShort = fieldnames(signalInfo(1,1).features);
featureNamesShort(end) = [];
numFeaturesShort = length(featureNamesShort);

for i = 1:numChannel
    changingClassTemp = numBurstsMaxChannel(1,i);
    signalInfo(changingClassTemp,1).signalClassification.burstDetection.spikePeaksValue(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.burstDetection.spikeLocs(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.burstDetection.burstEndValue(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.burstDetection.burstEndLocs(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.burstDetection.selectedBurstsIndex{i,1}(numBurstsMin(1,i)+1:end,1) = nan;
    
    signalInfo(changingClassTemp,1).signalClassification.selectedWindows.burst(:,numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.selectedWindows.burstMean = mean(signalInfo(changingClassTemp,1).signalClassification.selectedWindows.burst,2);
    signalInfo(changingClassTemp,1).signalClassification.selectedWindows.xAxisValues(:,numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).signalClassification.selectedWindows.numBursts = numBurstsMin';
    
    for j = 1:numFeatures
        signalInfo(changingClassTemp,1).signalClassification.features.(featureNames{j,1})(numBurstsMin(1,i)+1:end,i) = nan;
    end
    
    numTrain(i,1) = floor(numBurstsMin(1,i)*trainingRatio);
    numTest(i,1) = numBurstsMin(1,i) - numTrain(i,1);
    signalInfo(changingClassTemp,1).signalClassification.grouping.all(numBurstsMin(1,i)+1:end,1,i) = nan;
    for j = 1:numClass
        signalInfo(j,1).signalClassification.grouping.training(numTrain+1:end,1,i) = nan;
        signalInfo(j,1).signalClassification.grouping.testing(numTest+1:end,1,i) = nan;
        signalInfo(j,1).signalClassification.grouping.trainingClass(numTrain+1:end,1,i) = nan;
        signalInfo(j,1).signalClassification.grouping.testingClass(numTest+1:end,1,i) = nan;
    end
    
    signalInfo(changingClassTemp,1).windowsValues.burst(:,numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).windowsValues.burstMean = mean(signalInfo(changingClassTemp,1).windowsValues.burst,2);
    signalInfo(changingClassTemp,1).windowsValues.xAxisValues(:,numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).windowsValues.numBursts = numBurstsMin;
    
    for j = 1:numFeatures
        signalInfo(changingClassTemp,1).features.(featureNames{j,1})(numBurstsMin(1,i)+1:end,i) = nan;
    end

    signalInfo(changingClassTemp,1).detectionInfo.spikePeaksValue(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).detectionInfo.spikeLocs(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).detectionInfo.burstEndValue(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).detectionInfo.burstEndLocs(numBurstsMin(1,i)+1:end,i) = nan;
    signalInfo(changingClassTemp,1).detectionInfo.selectedBurstsIndex{i,1}(numBurstsMin(1,i)+1:end,1) = nan;
end

output = signalInfo;
end

