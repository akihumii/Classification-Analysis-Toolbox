function output = reconstructSignalInfoFeatures(signalInfo,parameters)
%reconstructSignalInfoFeatures Reconstruct features in signalInfo to fit
%the structure to run the reconstructFeatures later on.
%
%   output = reconstructSignalInfoFeatures(signalInfo,parameters)

numClass = length(signalInfo);
featureNames = fieldnames(signalInfo(1,1).features);
featureNames(end) = []; % the last field is the name of the analysed data but not the featuresName
numChannel = size(signalInfo(1,1).features.(featureNames{1,1}),2);
numFeatures = length(featureNames);

% Initialize
for i = 1:numChannel
    for j = 1:numFeatures
        output(i,1).(featureNames{j,1}) = zeros(0,0);
        if parameters.editMeanValueFeature
            meanValueTemp{i,1} = zeros(0,0);
        end
    end
end
        


for i = 1:numClass
    for j = 1:numChannel
        locsTemp = ~isnan(signalInfo(i,1).features.(featureNames{1,1})(:,j)) & signalInfo(i,1).features.(featureNames{1,1})(:,j) ~= 0;
        for k = 1:numFeatures
            output(j,1).(featureNames{k,1}) = [output(j,1).(featureNames{k,1}) ; signalInfo(i,1).features.(featureNames{k,1})(locsTemp,j)];
        end
        if parameters.editMeanValueFeature
            dataRectified = abs(signalInfo(i,1).windowsValues.burst(:,:,j));
            dataRectified = transpose(dataRectified(:,locsTemp));
            meanValueTemp{j,1} = [meanValueTemp{j,1};nanmean(dataRectified,2)];
        end
    end
end

if parameters.editMeanValueFeature
    for i = 1:numChannel
        output(i,1).meanValue = meanValueTemp{i,1};
    end
end

end

