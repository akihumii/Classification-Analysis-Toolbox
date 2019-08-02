function class = getGroundTruth(signal, signalClassificationInfo, handle)
%GETGROUNDTRUTH To be used for getting ground truth throughout entire data
% class = getGroundTruth(signal, signalClassificationInfo, handle)
lenData = size(signal.dataRaw,1);
stepArray = floor(handle.UserData.overlapWindowSize*signal.samplingFreq: handle.UserData.overlapWindowSize*signal.samplingFreq: lenData-str2num(handle.inputWindowSize.String));
lenStepArray = length(stepArray);
class = max(handle.UserData.activationClass)+1 * ones(lenStepArray-1,1);
for i = 1:lenStepArray
    pattern = any(stepArray(1,i) > signalClassificationInfo.burstDetection.spikeLocs &...
        stepArray(1,i) < signalClassificationInfo.burstDetection.burstEndLocs, 1);
    locs = all(pattern == handle.UserData.activationPattern, 2);
    if any(locs)
        class(i,1) = handle.UserData.activationClass(locs);
    end
end
end
