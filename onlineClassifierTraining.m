function [] = onlineClassifierTraining(varargin)
%TRAINCLASSFIIER Train the classifier and get the thresholds and some
%parameters for the online decoding
%   [] = onlineClassifierTraining()

%% Parameters
parameters = struct(...
    'featureClassification',4); % corresponds to area under the curve

parameters = varIntoStruct(parameters, varargin);

%% Pre-train
[signal,signalClassificationInfo] = mainClassifier(); % to detect the bursts

[classifierOutput,numClass] = analyzeFeatures(); % to train the classifier

%% Save required information for online classification
numFiles = length(signal);

for i = 1:numFiles
    thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
end
thresholdsAverage = mean(thresholds,1);

parameters.thresholds = thresholdsAverage;
parameters.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOStartConsecutivePoints;
parameters.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOEndConsecutivePoints;
parameters.samplingFreq = signal(1,1).samplingFreq;

parameters.classifierMdl = classifierOutput.classificationOutput{1,1}(parameters.featureClassification,1);
parameters.numClass = numClass + 1;

saveVar(fullfile(signal(1,1).path,'Info','onlineClassification'),'OnlineClassificationInfo',parameters);

popMsg('Training finished...');




end

