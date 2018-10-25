function [] = onlineClassifierTraining(varargin)
%TRAINCLASSFIIER Train the classifier and get the thresholds and some
%parameters for the online decoding
%   [] = onlineClassifierTraining()

%% Pre-train
[signal,signalClassificationInfo] = mainClassifier(); % to detect the bursts

[classifierOutput] = analyzeFeatures(); % to train the classifier

%% Save required information for online classification
numClass = length(signal);

%% For merging the channelInfo
% for i = 1:numClass
%     thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
%     parameters.classifierMdl(i,1) = classifierOutput(i,1).classificationOutput{1,1}(parameters.featureClassification,1).Mdl(i,1);
% end
% thresholdsAverage = mean(thresholds,1);
% 
% parameters.thresholds = thresholdsAverage;
% parameters.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOStartConsecutivePoints;
% parameters.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOEndConsecutivePoints;
% parameters.samplingFreq = signal(1,1).samplingFreq;
% 
% parameters.classifierMdl = classifierOutput.classificationOutput{1,1}(parameters.featureClassification,1);
% parameters.numClass = numClass + 1;


for i = 1:numClass
    thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
end
thresholdsAverage = mean(thresholds,1);

for i = 1:numClass
    parameters{i,1}.featureClassification = 5;
    parameters{i,1}.classifierMdl = classifierOutput(i,1).classificationOutput{1,1}(parameters{i,1}.featureClassification,1).Mdl{i,1};
    parameters{i,1}.thresholds = thresholdsAverage(1,i);
    parameters{i,1}.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOStartConsecutivePoints(1,i);
    parameters{i,1}.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOEndConsecutivePoints(1,i);
    parameters{i,1}.samplingFreq = signal(1,1).samplingFreq;
    parameters{i,1}.numClass = length(unique(classifierOutput(i,1).classificationOutput{1,1}(1,1).trainingClass{1,1}));
end

saveVar(fullfile(signal(1,1).path,'Info','onlineClassification'),'OnlineClassificationInfo',parameters);

popMsg('Training finished...');




end

