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
channel = [4,5,11,12]; % input channel for decoding
saveRaw = 0; % save raw signal plot
showRaw = 1; % show raw signal plot

%% Read data cnd Reconstruct
samplingFreq = 1800;        % Sampling Frequency

[files,path] = selectFiles(); % select file for decoding

[dataAll,time] = reconstructData(files{1},path,'sylphx'); % read and reconstruct data
time = time/samplingFreq; % convert into seconds

%% Plot 
fileName = files{1}(1:end-4); % get a file name

plotFig(time,dataAll(:,channel),fileName,'Raw Signal','Time(s)','Amplidute(V)',saveRaw,showRaw,path,'subplot',channel); % plot raw signals

%% Distance between sync pulses and peaks
% deletePairs = [];
% distance = findFirstPeaks(data, reconstructedSignal, deletePairs);

%% Delay Analysis
channelRectify = [4,5]; % to rectify signal
channelCounter = 11; % counter channel

dataRectified = dataAll;
dataRectified(:,channelRectify) = filterData(dataRectified(:,channelRectify),samplingFreq,10,0,0); % pass through a high pass filter for specified channels
dataRectified(:,channelRectify) = abs(dataAll(:,channelRectify)); % rectify the specified channels
dataRectified(:,channelRectify) = pulse2spike(dataRectified(:,channelRectify)); % convert pusle into spike

% delayAnalysis = pulse2spike(); % analyse cross correlation between two signals


%% End
finishMsg; % pop a message box to show the end of code
