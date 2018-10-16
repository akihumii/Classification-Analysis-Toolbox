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
    thresholds = signalClassificationInfo(i,1).burstDetection.threshold;
    numStartConsecutivePoints = signalClassificationInfo(i,1).burstDetection.TKEOStartConsecutivePoints;
    numEndConsecutivePoint = signalClassificationInfo(i,1).burstDetection.TKEOEndConsecutivePoints;
    samplingFreq = signal(i,1).samplingFreq;
    
    saveVar(fullfile(signal(i,1).path,'Info','onlineClassification'),[signal(i,1).fileName,'OnlineClassificationInfo'],...
        thresholds, numStartConsecutivePoints, numEndConsecutivePoint, samplingFreq);
end
        



end

