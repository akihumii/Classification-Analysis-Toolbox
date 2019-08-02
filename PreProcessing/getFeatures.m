function features = getFeatures(signal, handle, class)
%GETFEAURES To be used for getting all the windows within entire signal.
%   Detailed explanation goes here
lenData = size(signal.dataRaw,1);
stepArray = floor(1: handle.UserData.overlapWindowSize*signal.samplingFreq:...
                    lenData-str2num(handle.inputWindowSize.String)/1000*signal.samplingFreq);
lenStepArray = length(stepArray);
for i = 1:lenStepArray-1
%     dataTemp = 
    features(1,i) = featureExtraction(...
                    signal.dataRaw(stepArray(1,i):stepArray(1,i)+str2num(handle.inputWindowSize.String)/1000*signal.samplingFreq,:),...
                    signal.samplingFreq, handle.UserData.featuresForClassification);
end
features = squeeze(struct2cell(features));
for i = 1:size(features,1)
    featuresEdited{i,1} = horzcat(features{i,:})';
end
features = horzcat(featuresEdited{:,1});
end

