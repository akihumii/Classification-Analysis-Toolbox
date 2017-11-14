function output = findFirstPeaks(extractedData, reconstructedSignal, deletePairs)
%findFirstPeaks
%   certain signs and minPeaks might need to change according to the signal
close all

samplingFreq = 1800;

%% User Input
channel = 5;
threshold = 4.3e-4;
sign = 1; % reverse signal to find peaks or not, input 1 or -1
skipWindow = samplingFreq * 0.07; % s
skipWindowEnd = samplingFreq * 0.08

[syncPulses,syncPulsesLocs] = findpeaks(extractedData.data(1:end,11)); % peaks and locs of sync pulses

[stimulatedPulses,stimulatedPulsesLocs] = findpeaks(sign * reconstructedSignal.yValues(channel,:),'minPeakHeight',threshold); % all the peaks and locs of spikes after pulses, sign and minPeakHeight might need to change according to signal

firstPeakLocs = zeros(0,1);
firstPeak = zeros(0,1);
for i = 1:length(syncPulses)
    firstPeak = [firstPeak; stimulatedPulses(find(stimulatedPulsesLocs > (syncPulsesLocs(i)+skipWindow),1))]; % y value of first spike after artefact, sign of y2 might need to change according to signal
    firstPeakLocs = [firstPeakLocs; stimulatedPulsesLocs(find(stimulatedPulsesLocs > (syncPulsesLocs(i)+skipWindow),1))]; % location of the first spike after artefact
end

%% delete unwanted burst
firstPeak(deletePairs) = [];
firstPeakLocs(deletePairs) = [];
syncPulsesLocs(deletePairs) = [];

%% Plotting 
figure
plot(sign * reconstructedSignal.yValues(channel,:)); % one channel that contains pulses
hold on

plot(firstPeakLocs,firstPeak,'ro') % circle the first peaks on the spikes figure
plot(syncPulsesLocs,.5e-3*extractedData.data(syncPulsesLocs,11)/255,'kx') % cross with the pulses timing, plot on the spike figure
plot(.5e-3*extractedData.data(:,11)/255) % plot sync pulse on the same plots

legend('signal','first peak','sync pulse')

%% counter
counter = extractedData.data(1:end,12);
counterDiff = diff(counter);
counterSkipLocs = find(counterDiff~=1 & counterDiff~=-65534);
counterSkipNum = length(counterSkipLocs); 
counterSkipPerc = counterSkipNum/length(counter);

%% Analyse
distance = (firstPeakLocs-syncPulsesLocs)/samplingFreq; % distance between first spike location and pulse location prior to it
output.syncPulsesLocs = syncPulsesLocs;
output.distance = distance;
output.firstPeakLocs = firstPeakLocs;
output.s = std(distance); % standard deviation
output.m = mean(distance); % mean
output.minimum = min(distance); % min
output.maximum = max(distance); % max
output.counterSkipLocs = counterSkipLocs; % location of skipping points
output.counterSkipNum = counterSkipNum; % number of skiiping points
output.counterSkipPerc = counterSkipPerc; % percentage of skipping points over the entire trial

end

