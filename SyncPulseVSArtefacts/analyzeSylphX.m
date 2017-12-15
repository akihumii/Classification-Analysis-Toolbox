%% analyzeSylphX
% Read, plot and calculate standard deviation of delay between sync pulse
% and stimulated pulses.
%
% Counter will be analysed for error occurrence
%
% Coded by Tsai Chne Wuen

clear
close all
clc

%% User Input
channel = [4,11,12]; % input channel for decoding
channelData = 4; % to rectify signal
channelSync = 11; % sync pulse
channelCounter = 12; % counter channel

saveRaw = 0; % save raw signal plot
showRaw = 1; % show raw signal plot
minDistance = 1; % minimum distance between two spikes (in seconds)
threshold = [1e-3,1e-4,200]; % threshlod to detect peaks
deleteBursts = []; % bursts index to delete
deleteTolerance = 0.1; % maximum distance between one pair of corresponding spikes which are in a tirggering/triggered relationship (in seconds)

%% Read data cnd Reconstruct
samplingFreq = 1000;        % Sampling Frequency

[files,path] = selectFiles(); % select file for decoding

[dataAll,time] = reconstructData(files{1},path,'sylphx'); % read and reconstruct data
time = time/samplingFreq; % convert into seconds

%% Plot
fileName = files{1}(1:end-4); % get a file name

plotFig(time,dataAll(:,channel),fileName,'Raw Signal','Time(s)','Amplidute(V)',saveRaw,showRaw,path,'subplot',channel); % plot raw signals

%% Delay Analysis
channelPlot = [channelData,channelSync];

dataRectified = dataAll;
dataRectified(:,channelData) = filterData(dataRectified(:,channelData),samplingFreq,10,0,0); % pass through a high pass filter for specified channels
dataRectified(:,channelData) = abs(dataRectified(:,channelData)); % rectify the specified channels
spikeInfo = pulse2spike(dataRectified(:,channelPlot),samplingFreq,minDistance,threshold); % convert pusle into spike

%% Trim bursts
[spikeInfo.spikeLocs,spikeInfo.spikePeaks] = trimCorrespondingSpikes(spikeInfo.spikeLocs/samplingFreq,deleteTolerance,spikeInfo.spikePeaks);

%% Delete Bursts
spikeInfo.spikeLocs(deleteBursts,1) = [];
spikeInfo.spikePeaks(deleteBursts,1) = [];

s = plotFig(spikeInfo.spikeLocs,spikeInfo.spikePeaks,'','','Time(s)','Amplitude(V)',0,1,'','subplot',0,'stemPlot');
numPlots = size(spikeInfo.spikePeaks,2);
for i = 1:numPlots
    axes(s(i,1));
    hold on
    plot(time,dataRectified(:,channelPlot(i)))
    numSpike = sum(~isnan((spikeInfo.spikePeaks(:,i))));
    for j = 1:numSpike
        text(spikeInfo.spikeLocs(j,i),0,num2str(j));
    end
end

%% Analyze counter
counterInfo = analyseContValue(dataRectified(:,channelCounter),[1,-65535]);

%% Result
result = getBasicParameter(abs(spikeInfo.spikeLocs(:,1) - spikeInfo.spikeLocs(:,2)));

% delayStdArray = xcorr(spikeInfo.spikeLocs(:,1),spikeInfo.spikeLocs(:,2));
% delayStdMean = mean(delayStdArray);

%% End
finishMsg; % pop a message box to show the end of code
