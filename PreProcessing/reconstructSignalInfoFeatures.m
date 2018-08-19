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

% Initialize
for i = 1:numChannel
    for j = 1:numFeatures
        output(i,1).(featureNames{j,1}) = zeros(0,0);
    end
end
        

for i = 1:numClass
    for j = 1:numChannel
        locsTemp = ~isnan(signalInfo(i,1).features.(featureNames{1,1})(:,j)) & signalInfo(i,1).features.(featureNames{1,1})(:,j) ~= 0;
        for k = 1:numFeatures
            output(j,1).(featureNames{k,1}) = [output(j,1).(featureNames{k,1}) ; signalInfo(i,1).features.(featureNames{k,1})(locsTemp,j)];
        end
    end
end

end

