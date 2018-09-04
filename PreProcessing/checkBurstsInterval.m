function [] = checkBurstsInterval(varargin)
%CHECKBURSTSINTERVAL Check the burst interval to see their actual speed
% 
%   Detailed explanation goes here

close all

%% Default Parameters
parameters = struct(...
    'useHPC',0,...
    'xbinsWidth',0.2);

parameters = varIntoStruct(parameters,varargin{1,:}); % to load the varargin into 

%% Load data
if parameters.useHPC
    allFiles = dir('*.mat');
    iters = length(allFiles);
    path = [pwd,filesep];
else
    [files, path, iters] = selectFiles('select mat files for classifier''s training');
end

%% Read and Reconstruct
for i = 1:iters
    files{1,i} = allFiles(i,1).name;
    signalInfo(i,1) = getFeaturesInfo(path,files{1,i});
end

%% Get bursts intervals
numChannel = size(signalInfo(1,1).signalClassification.burstDetection.spikeLocs,2);

for i = 1:iters
    burstInterval{i,1} = diff(signalInfo(i,1).signalClassification.burstDetection.spikeLocs);
    burstInterval{i,1} = vertcat(burstInterval{i,1}, nan(1,numChannel)); % for the last set of bursts
    burstIntervalAllSeconds{i,1} = burstInterval{i,1} / signalInfo(i,1).samplingFreq;
end

burstIntervalAll = squeezeNan(vertcat(burstIntervalAllSeconds{:,1}),2);

for i = 1:numChannel
    BITemp = burstIntervalAll(:,i);
    xbinsTemp = min(BITemp) : parameters.xbinsWidth : max(BITemp);
    figure
    hist(BITemp, xbinsTemp);
end
end
