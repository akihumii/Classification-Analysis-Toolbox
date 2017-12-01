function output = findFirstPeaks(extractedData, reconstructedSignal, deletePairs)
%findFirstPeaks
%   certain signs and minPeaks might need to change according to the signal
samplingFreq = 1777;

%% User Input
channel = 4;
threshold = 4.3e-4;
sign = 1; % input 1 to find peaks upwards, input -1 to find peaks downwards
skipWindow = samplingFreq * 0.03; % skip a certain distance before starting to find the first peak

%% Find Peaks
numData = length(extractedData.data(:,11));

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
plot(1/samplingFreq:1/samplingFreq:numData/samplingFreq,sign * reconstructedSignal.yValues(channel,:)); % one channel that contains pulses
hold on

plot(firstPeakLocs/samplingFreq,firstPeak,'ro') % circle the first peaks on the spikes figure
plot(syncPulsesLocs/samplingFreq,.5e-3*extractedData.data(syncPulsesLocs,11)/255,'kx') % cross with the pulses timing, plot on the spike figure
plot(1/samplingFreq:1/samplingFreq:numData/samplingFreq,.5e-3*extractedData.data(:,11)/255) % plot sync pulse on the same plots
for i = 1:length(syncPulsesLocs)
    text(syncPulsesLocs(i)/samplingFreq,0,num2str(i)); % label number of sync pulse
    t = text(firstPeakLocs(i)/samplingFreq,-1e-4,num2str(i)); % label number of first peak
    t.Color = [1 0 0]; % change the color into red corlor
end

legend('signal','first peak','sync pulse')
title(['Channel ',num2str(channel)]);
xlabel('Time(s)');
ylabel('Amplitude(V)');
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
output.standardDeviationValue = std(distance); % standard deviation
output.meanDelay = mean(distance); % mean in seconds
output.minimumDelay = min(distance); % min in seconds
output.maximumDelay = max(distance); % max in seconds
output.counterSkipLocs = counterSkipLocs; % location of skipping points
output.counterSkipNum = counterSkipNum; % number of skiping points
output.counterSkipPerc = counterSkipPerc; % percentage of skipping points over the entire trial

end
