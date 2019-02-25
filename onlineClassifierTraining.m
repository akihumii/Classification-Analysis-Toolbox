function [] = onlineClassifierTraining(varargin)
%TRAINCLASSFIIER Train the classifier and get the thresholds and some
%saveInfo for the online decoding
%   [] = onlineClassifierTraining()

[threshMultStr, signal, signalClassificationInfo, saveFileName] = onlineClassifierDetectBursts();

classifierOutput = analyzeFeatures('numFeaturesInCombination',2,'featureIndexSelected',{[5,7]},'selectFileType',2,'specificTarget',saveFileName,'showAccuracy',0,'saveAccuracy',0); % to train the classifier



%% Save required information for online classification
numClass = length(signal);

%% For merging the channelInfo
% for i = 1:numClass
%     thresholds(i,:) = signalClassificationInfo(i,1).burstDetection.threshold;
%     saveInfo.classifierMdl(i,1) = classifierOutput(i,1).classificationOutput{1,1}(saveInfo.featureClassification,1).Mdl(i,1);
% end
% thresholdsAverage = mean(thresholds,1);
% 
% saveInfo.thresholds = thresholdsAverage;
% saveInfo.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.saveInfo.TKEOStartConsecutivePoints;
% saveInfo.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.saveInfo.TKEOEndConsecutivePoints;
% saveInfo.samplingFreq = signal(1,1).samplingFreq;
% 
% saveInfo.classifierMdl = classifierOutput.classificationOutput{1,1}(saveInfo.featureClassification,1);
% saveInfo.numClass = numClass + 1;

for i = 1:numClass
    saveInfo{i,1}.featureClassification = classifierOutput(1).featureIndex{1,1};
    saveInfo{i,1}.classifierMdl = classifierOutput(i,1).classificationOutput{1,1}(1,1).Mdl{i,1};
    saveInfo{i,1}.thresholds = signalClassificationInfo(i,1).burstDetection.threshold(i,1);
    saveInfo{i,1}.numStartConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOStartConsecutivePoints(1,i);
    saveInfo{i,1}.numEndConsecutivePoints = signalClassificationInfo(1,1).burstDetection.parameters.TKEOEndConsecutivePoints(1,i);
    saveInfo{i,1}.samplingFreq = signal(1,1).samplingFreq;
    saveInfo{i,1}.numClass = length(unique(classifierOutput(i,1).classificationOutput{1,1}(1,1).trainingClass{1,i}));
    saveInfo{i,1}.threshMultStr = threshMultStr;
end

saveVar(fullfile(signal(1,1).path,'Info','onlineClassification'),['OnlineClassificationInfo_',cell2mat(join(threshMultStr,'n'))],saveInfo);

popMsg('Training finished...');




end

