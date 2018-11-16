function [] = charateriseClassifier()
%CHARACTERISCLASSIFIER Characterise the classifier
%   [] = charateriseClassifier()

close all

%% Parameters
parameters = struct(...
    'movingWindowSize',150,...
    'overlapWindowSize',50,...
    'featureIndex',5,...
    'samplingFreq',1000,...
    'showPlotFlag',1,...
    'savePlotFlag',1,...
    'autoSelectFiles',0);

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
if ~parameters.autoSelectFiles
    [filesSignal,pathSignal,iters] = selectFiles('Select the signal info .mat file...');
    [filesClassifier,pathClassifier] = selectFiles('Select the classifier info .mat file...');
    [filesLocs,pathLocs] = selectFiles('Select the burst locations info .mat file...');
else
    iters = 1;
    pathSignal = 'C:\Users\lsitsai\Desktop\Derek\Derek Bicep and Forearm\20181108\testing\Info\';
end

%% Assignation
% parameters.endPartLength = parameters.movingWindowSize / 4;
for i = 1:iters
    if ~parameters.autoSelectFiles
        signalInfo(i,1) = load(fullfile(pathSignal,filesSignal{1,i}));
        classifierInfo(i,1) = load(fullfile(pathClassifier,filesClassifier{1,i}));
        locsInfo(i,1) = load(fullfile(pathLocs,filesLocs{1,i}));
    else
        signalInfo(i,1) = load('C:\Users\lsitsai\Desktop\Derek\Derek Bicep and Forearm\20181108\testing\Info\data 20181108 160358_20181113172720.mat');
        classifierInfo(i,1) = load('C:\Users\lsitsai\Desktop\Derek\Derek Bicep and Forearm\20181108\testing\Info\classificationInfo\data 20181108 160358_20181113172720_20181113172731.mat');
        locsInfo(i,1) = load('C:\Users\lsitsai\Desktop\Derek\Derek Bicep and Forearm\20181108\testing\Info\data 20181108 160358_20181113174320.mat');
    end
    
    dataFiltered{i,1} = signalInfo(i,1).varargin{1,1}.dataFiltered.values(:,i);
    classifierMdl{i,1} = classifierInfo(i,1).varargin{1,1}.classificationOutput{1,1}(parameters.featureIndex).Mdl{i,1};
    burstStartLocs{i,1} = squeezeNan(locsInfo(i,1).varargin{1, 2}.burstDetection.spikeLocs(:,i),2);
    burstEndLocs{i,1} = squeezeNan(locsInfo(i,1).varargin{1, 2}.burstDetection.burstEndLocs(:,i),2);
end

%% Active window determination & Classification
[trueClass,predictClass] = getTrueNPredictClass(dataFiltered,classifierMdl,burstStartLocs,burstEndLocs,parameters);

%% Check Delay and 
accuracyInfo = checkOnlineAccuracy(predictClass, trueClass);

checkLocsNPlot(dataFiltered,accuracyInfo,parameters,pathSignal);

popMsg('Finished...');

end

