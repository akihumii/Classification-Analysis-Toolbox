%% analyzeSylphX
% Read, plot and calculate standard deviation of delay between sync pulse
% and stimulated pulses.
% 
% output:   counterInfo: Counter will be analysed for error occurrence
%           result:     delay between channelData and channelSync will be
%                       analyzed
%
% Coded by Tsai Chne Wuen

clear
close all
% clc

%% User Input
channel = [4,5,11,12]; % the channel that will be plotted in the first figure
channelData = 4; % the channel that will be analyzed together with channelSync, can only input one channel
channelSync = 11; % sync pulses channel
channelCounter = 12; % counter channel

saveRaw = 0; % save raw signal plot
showRaw = 1; % show raw signal plot
minDistance = .5; % minimum distance between two spikes (in seconds)
threshold = [0.5e-3,200]; % threshlod to detect peaks, input 0 for default (baseine + 5 * standard deviation of baseline)
deleteBursts = []; % bursts index to delete
deleteTolerance = 0.5; % maximum distance between one pair of corresponding spikes which are in a tirggering/triggered relationship (in seconds)

samplingFreq = 1000; % Sampling Frequency
peakDetectionType = 'local maxima'; % peak detection type in pulse2spike function

%% Read data cnd Reconstruct

[files,path] = selectFiles(); % select file for decoding

[dataAll,time] = reconstructData(files{1},path,'sylphx'); % read and reconstruct data
time = time/samplingFreq; % convert into seconds

%% Plot
fileName = files{1}(1:end-4); % get a file name

plotFig(time,dataAll(:,channel),fileName,'Raw Signal','Time(s)','Amplidute(V)',saveRaw,showRaw,path,'subplot',channel); % plot raw signals

%% Delay Analysis
channelPlot = [channelData,channelSync]; % channels to be analysed for their pulses

dataRectified = dataAll;
dataRectified(:,channelData) = filterData(dataRectified(:,channelData),samplingFreq,10,0,0); % pass through a high pass filter for specified channels
dataRectified(:,channelData) = abs(dataRectified(:,channelData)); % rectify the specified channels
spikeInfo = pulse2spike(dataRectified(:,channelPlot),samplingFreq,minDistance,threshold,peakDetectionType); % convert pusle into spike

%% Trim bursts
[spikeInfoTrimmed.spikeLocs,spikeInfoTrimmed.spikePeaks] = trimCorrespondingSpikes(spikeInfo.spikeLocs/samplingFreq,deleteTolerance,spikeInfo.spikePeaks); % remove the spikes that are apart from the 2 nearest corresponding spikes further than the distance of deleteTolerance

%% Delete Bursts
% to delete the pulses that are inappropriate
spikeInfoTrimmed.spikeLocs(deleteBursts,:) = [];
spikeInfoTrimmed.spikePeaks(deleteBursts,:) = [];

s = plotFig(spikeInfoTrimmed.spikeLocs,spikeInfoTrimmed.spikePeaks,'','','Time(s)','Amplitude(V)',0,1,'','subplot',0,'stemPlot');
numPlots = size(spikeInfoTrimmed.spikePeaks,2);
for i = 1:numPlots
    axes(s(i,1));
    hold on
    grid minor
    plot(time,dataRectified(:,channelPlot(i)))
    numSpike = sum(~isnan((spikeInfoTrimmed.spikePeaks(:,i))));
    for j = 1:numSpike
        text(spikeInfoTrimmed.spikeLocs(j,i),0,num2str(j)); % input text under the spikes
    end
end

%% Analyze counter
% counterInfo = analyseContValue(dataRectified(:,channelCounter),[1,-65535]); % analyze the counter and output the histogram and the distribution of the skipping data

%% Result
spikeDiff = spikeInfoTrimmed.spikeLocs(:,1) - spikeInfoTrimmed.spikeLocs(:,2); % spike difference
result = getBasicParameter(abs(spikeDiff)); % result info of distance, standard deviation etc of the spikes
numSpikeDiff = length(spikeDiff);
sD = plotFig(1:numSpikeDiff,sort(spikeDiff),'','Spike Difference (Channel - Sync Pulse)','Index number of Difference','Time (s)',0,1,'','subplot',0,'stemPlot');
hold on
grid minor
fivePerc = plot([numSpikeDiff*.05,numSpikeDiff*.05],ylim,'r--'); 
% delayStdArray = xcorr(spikeInfo.spikeLocs(:,1),spikeInfo.spikeLocs(:,2));
% delayStdMean = mean(delayStdArray);

%% End
finishMsg; % pop a message box to show the end of code
