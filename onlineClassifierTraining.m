function [] = onlineClassifierTraining()
%TRAINCLASSFIIER Train the classifier and get the thresholds and some
%parameters for the online decoding
%   [] = onlineClassifierTraining()

%% Pre-train
[signal,signalClassificationInfo] = mainClassifier(); % to detect the bursts

% analyzeFeatures(); % to train the classifier

%% Save required information for online classification
numFiles = length(signal);

for i = 1:numFiles
    thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
end
thresholdsAverage = mean(thresholds,1);

parameters.thresholds = thresholdsAverage;
parameters.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.TKEOStartConsecutivePoints;
parameters.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.TKEOEndConsecutivePoints;
parameters.samplingFreq = signal(1,1).samplingFreq;

saveVar(fullfile(signal(1,1).path,'Info','onlineClassification'),'OnlineClassificationInfo',parameters);





end

