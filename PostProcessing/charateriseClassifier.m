function [] = charateriseClassifier()
%CHARACTERISCLASSIFIER Characterise the classifier
%   [] = charateriseClassifier()

close all

%% Parameters
parameters = struct(...
    'movingWindowSize',200,...
    'endPartLength',35,...
    'overlapWindowSize',50,...
    'featureIndex',5,...
    'samplingFreq',1000);

parameters.featureNamesAll = {...
    'maxValue';...
    'minValue';...
    'burstLength';...
    'areaUnderCurve';...
    'meanValue';...
    'sumDifferences';...
    'numZeroCrossings';...
    'numSignChanges'};

%% Select files
[filesSignal,pathSignal,iters] = selectFiles('Select the signal info .mat file...');
[filesClassifier,pathClassifier] = selectFiles('Select the classifier info .mat file...');

%% Assignation
for i = 1:iters
    signalInfo(i,1) = load(fullfile(pathSignal,filesSignal{1,i}));
    classifierInfo(i,1) = load(fullfile(pathClassifier,filesClassifier{1,i}));
    
    dataTKEO{i,1} = signalInfo.varargin{1,1}.dataTKEO.values(:,i);
    dataFiltered{i,1} = signalInfo.varargin{1,1}.dataFiltered.values(:,i);
    threshold(i,1) = signalInfo.varargin{1,2}.burstDetection.threshold(i,1);
    classifierMdl{i,1} = classifierInfo.varargin{1,1}.classificationOutput{1,1}(parameters.featureIndex).Mdl{i,1};
end

%% Active window determination & Classification
[trueClass,predictClass] = getTrueNPredictClass(dataTKEO,dataFiltered,threshold,classifierMdl,parameters);

%% Check Delay and 
accuracyInfo = checkOnlineAccuracy(predictClass, trueClass);

checkLocsNPlot(dataFiltered{1,1},accuracyInfo.classifiedInd,parameters,threshold);

end

