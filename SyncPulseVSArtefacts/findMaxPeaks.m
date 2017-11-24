function output = findMaxPeaks(extractedData, reconstructedSignal, deletePairs)
%findFirstPeaks Plot the maximum point in the window in between two sync
%pulses
% Certain signs and minPeaks might need to change according to the signal
% output = findFirstPeaks(extractedData, reconstructedSignal, deletePairs)
samplingFreq = 128;

%% User Input
channel = 1;
sign = 1; % input 1 to find peaks upwards, input -1 to find peaks downwards
minSyncPulseDistance = samplingFreq * 1;

%% Find Peaks
numData = length(extractedData.data(:,2));

[syncPulses,syncPulsesLocs] = findpeaks(-extractedData.data(:,2),'minPeakHeight',-2.5,'minPeakDistance',minSyncPulseDistance); % peaks and locs of sync pulses

[maxForcePoints,maxForcePointsPlotting,maxForcePointsLocs,baseline] =...
    sortMaxPeaks(syncPulsesLocs,reconstructedSignal.yValues(channel,:));

%% delete unwanted burst
syncPulsesLocs(deletePairs) = [];
maxForcePoints(deletePairs) = [];
maxForcePointsLocs(deletePairs) = [];

%% Plotting 
figure
ax(1) = subplot(211);
plot(reconstructedSignal.yValues(3,:),reconstructedSignal.yValues(2,:)); % sync pulse diagram
hold on
plot(reconstructedSignal.yValues(3,syncPulsesLocs),reconstructedSignal.yValues(2,(syncPulsesLocs)),'kx') % cross with the pulses timing, plot on the spike figure
grid on

title('Sync Pulse')

ax(2) = subplot(212);
plot(reconstructedSignal.yValues(3,:),sign * reconstructedSignal.yValues(channel,:)); % force diagram
hold on
grid on

rr = plot(reconstructedSignal.yValues(3,maxForcePointsLocs),maxForcePointsPlotting,'ro'); % circle the first peaks on the spikes figure
gg = plot(reconstructedSignal.yValues(3,maxForcePointsLocs),maxForcePoints,'g*'); % force point after minusing baseline
% plot(reconstructedSignal.yValues(3,:),.5e-3*extractedData.data(:,2)/255) % plot sync pulse on the same plots

title('Grip Force')
xlabel('Time(ms)')
ylabel('Force(N)')
legend([rr,gg],'ro','g*')

linkaxes(ax,'x');

%% Analyse
distance = (maxForcePointsLocs-syncPulsesLocs)/samplingFreq; % distance between first spike location and pulse location prior to it
output.syncPulsesLocs = syncPulsesLocs;
output.distance = distance;
output.baseline = baseline;
output.maxForcePointLocs = maxForcePointsLocs;
output.maxForcePoints = maxForcePoints;
output.standardDeviationValue = std(distance); % standard deviation
output.meanDelay = mean(distance); % mean in seconds
output.minimumDelay = min(distance); % min in seconds
output.maximumDelay = max(distance); % max in seconds

end

