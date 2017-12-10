function output = findFirstPeaks(extractedData, reconstructedSignal, deletePairs)
%findFirstPeaks Find the peaks in stimulation pulses and plot them in
%figures with x as trigger pulses and o as stimulation peak.
%   
%   output = findFirstPeaks(extractedData, reconstructedSignal, deletePairs)
samplingFreq = 1777;

%% User Input
channel = 4;
thresholdSyncPulse = 4.3e-4; % threshold for triggering pulse
thresholdStimulation = 4.3e-4; % threshold for stimulation pulse
sign = 1; % input 1 to find peaks upwards, input -1 to find peaks downwards
skipWindow = samplingFreq * 0.03; % skip a certain distance before starting to find the first peak
minDistance = 0; % minimum distance between two two triggering peaks

%% Find Peaks
stimulatePeakLocs = zeros(0,1);
stimulatePeak = zeros(0,1);
numData = length(extractedData.data(:,11));

syncPulseData = extractedData.data(1:end,11);
stimulationData = sign * reconstructedSignal.yValues(channel,:);

[stimulatePeak,stimulatePeakLocs] = triggerLocalSpikeDetection(syncPulseData,stimulationData,thresholdSyncPulse,thresholdStimulation,minDistance,skipWindow,stimulatePeak,stimulatePeakLocs);

[stimulatePeak,stimulatePeakLocs] = triggerLocalSpikeDetection(flipud(stimulationData),flipud(syncPulseData),thresholdStimulation,thresholdSyncPulse,minDistance,skipWindow,stimulatePeak,stimulatePeakLocs);

%% delete unwanted burst
stimulatePeak(deletePairs) = [];
stimulatePeakLocs(deletePairs) = [];
triggerPulsesLocs(deletePairs) = [];

%% Plotting 
figure
plot(1/samplingFreq:1/samplingFreq:numData/samplingFreq,sign * reconstructedSignal.yValues(channel,:)); % one channel that contains pulses
hold on

plot(stimulatePeakLocs/samplingFreq,stimulatePeak,'ro') % circle the first peaks on the spikes figure
plot(triggerPulsesLocs/samplingFreq,.5e-3*extractedData.data(triggerPulsesLocs,11)/255,'kx') % cross with the pulses timing, plot on the spike figure
plot(1/samplingFreq:1/samplingFreq:numData/samplingFreq,.5e-3*extractedData.data(:,11)/255) % plot trigger pulse on the same plots
for i = 1:length(triggerPulsesLocs)
    text(triggerPulsesLocs(i)/samplingFreq,0,num2str(i)); % label number of trigger pulse
    t = text(stimulatePeakLocs(i)/samplingFreq,-1e-4,num2str(i)); % label number of first peak
    t.Color = [1 0 0]; % change the color into red corlor
end

legend('signal','first peak','trigger pulse')
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
distance = (stimulatePeakLocs-triggerPulsesLocs)/samplingFreq; % distance between first spike location and pulse location prior to it
output.syncPulsesLocs = triggerPulsesLocs;
output.distance = distance;
output.firstPeakLocs = stimulatePeakLocs;
output.standardDeviationValue = std(distance); % standard deviation
output.meanDelay = mean(distance); % mean in seconds
output.minimumDelay = min(distance); % min in seconds
output.maximumDelay = max(distance); % max in seconds
output.counterSkipLocs = counterSkipLocs; % location of skipping points
output.counterSkipNum = counterSkipNum; % number of skiping points
output.counterSkipPerc = counterSkipPerc; % percentage of skipping points over the entire trial

end
