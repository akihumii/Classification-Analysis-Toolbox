function [] = onlineClassifierTraining()
%TRAINCLASSFIIER Train the classifier and get the thresholds and some
%parameters for the online decoding
%   [] = onlineClassifierTraining()

%% Pre-train
[signal,signalClassificationInfo] = mainClassifier(); % to detect the bursts

% analyzeFeatures(); % to train the classifier

%% Save required information for online classification
numFiles = length(signal);
numChannels = length(signalClassificationInfo(1,1).burstDetection.threshold);

for i = 1:numFiles
    thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
end
thresholdsAverage = mean(thresholds,1);

for i = 1:numChannels
    parameters(i,1).thresholds = thresholdsAverage(1,i);
    parameters(i,1).numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.TKEOStartConsecutivePoints(1,i);
    parameters(i,1).numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.TKEOEndConsecutivePoints(1,i);
    parameters(i,1).samplingFreq = signal(i,1).samplingFreq;
end

saveVar(fullfile(signal(i,1).path,'Info','onlineClassification'),[signal(i,1).fileName,'OnlineClassificationInfo'],parameters);

        



end

