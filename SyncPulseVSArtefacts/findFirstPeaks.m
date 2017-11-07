function output = findFirstPeaks(extractedData, reconstructedSignal)
%findFirstPeaks
%   certain signs and minPeaks might need to change according to the signal
close all

%% User Input
channel = 5;
threshold = 1e-3;
sign = 1; % reverse signal to find peaks or not, input 1 or -1

[syncPulses,syncPulsesLocs] = findpeaks(extractedData.data(1:end,11)); % peaks and locs of sync pulses

figure
plot(sign * reconstructedSignal.yValues(channel,:)); % one channel that contains pulses
hold on

[stimulatedPulses,stimulatedPulsesLocs] = findpeaks(sign * reconstructedSignal.yValues(channel,:),'minPeakHeight',threshold); % all the peaks and locs of spikes after pulses, sign and minPeakHeight might need to change according to signal

firstPeakLocs = zeros(0,1);
firstPeak = zeros(0,1);
for i = 1:length(syncPulses)
    firstPeak = [firstPeak; stimulatedPulses(find(stimulatedPulsesLocs>syncPulsesLocs(i),1))]; % y value of first spike after artefact, sign of y2 might need to change according to signal
    firstPeakLocs = [firstPeakLocs; stimulatedPulsesLocs(find(stimulatedPulsesLocs>syncPulsesLocs(i),1))]; % location of the first spike after artefact
end

plot(sign * firstPeakLocs,firstPeak,'ro') % circle the first peaks on the spikes figure
plot(syncPulsesLocs,reconstructedSignal.yValues(channel,syncPulsesLocs),'rx') % cross with the pulses timing, plot on the spike figure
plot(.5e-3*extractedData.data(:,11)/255) % plot sync pulse on the same plots

legend('signal','first peak','sync pulse')

%% counter
counter = extractedData.data(1:end,12);
counterDiff = diff(counter);
counterSkip = length(counterDiff(counterDiff~=1 & counterDiff~=-250)); 
counterSkipPerc = counterSkip/length(counter);

%% Analyse
distance = firstPeakLocs-syncPulsesLocs; % distance between first spike location and pulse location prior to it
output.firstPLocs = firstPeakLocs;
output.firstP = firstPeak;
output.s = std(distance); % standard deviation
output.m = mean(distance); % mean
output.minimum = min(distance); % min
output.maximum = max(distance); % max
output.counterSkip = counterSkip; % number of skipping points
output.counterSkipPerc = counterSkipPerc; % percentage of skipping points over the entire trial

end

