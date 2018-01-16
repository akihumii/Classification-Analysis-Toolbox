function combinedInfo = combineFeatures(saveFile)
%combineFeatures Combine features from two info files created by
%mainClassifier.m
% 
% input:    saveFile: input 1 to save the combined features with the remaining data in the first mat file, otherwise input 0;
% 
%   [combinedInfo] = combineFeatures(saveFileIndex)

%% Read files
[files,path,iter] = selectFiles('Select the mat files to combine their features');

for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    features(i,1) = signalClassification(i,1).features;
end

%% Combine features
featuresNames = fieldnames(features(1,1));
featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(featuresNames);

for i = 1:numFeatures
    combinedInfo.(featuresNames{i}) = vertcat(features(:).(featuresNames{i}));
end

%% Save it into one of the files, depending on saveFileIndex
if saveFile == 1
    combinedInfo.dataAnalysed = signalClassification(1,1).features.dataAnalysed;
    signalClassification(1,1).features = combinedInfo;
    saveVar(signal(1,1).path,horzcat(signal(:,1).fileName),signal(1,1),signalClassification(1,1))
end

finishMsg; % pop up a msg box to show FININSH :D

end

