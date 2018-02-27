function output = reconstructSignalInfoFeatures(signalInfo)
%reconstructSignalInfoFeatures Reconstruct features in signalInfo to fit
%the structure to run the reconstructFeatures later on.
%
%   output = reconstructSignalInfoFeatures(signalInfo)

numClass = length(signalInfo);
numChannel = length(signalInfo(1,1).signal.channel);
featureNames = fieldnames(signalInfo(1,1).features);
featureNames(end) = []; % the last field is the name of the analysed data but not the featuresName
numFeatures = length(featureNames);

for i = 1:numChannel
    for j = 1:numFeatures
        output(i,1).(featureNames{j,1}) = zeros(0,0);
        for k = 1:numClass
            output(i,1).(featureNames{j,1}) = [output(i,1).(featureNames{j,1}) ; signalInfo(k,1).features.(featureNames{j,1})(:,i)];
        end
    end
end

end

