%% analyzeSylphX

clear 
close all
clc

%% Variable to be changed
% Hardware variable
samplingFreq = 1800;        % Sampling Frequency
voltageStep = 0.000000195;  % Sylph's voltage step

period = 1/samplingFreq;

extractedData = loadData();

reconstructedSignal.yValues = zeros(10, size(extractedData.data(1:end,1), 1));

for i = 1:10
    reconstructedSignal.yValues(i,:) = reconstructSignal(extractedData.data(1:end,i), voltageStep);
end

reconstructedSignal.xValues = 0:size(extractedData.data(1:end,1), 1)-1;
reconstructedSignal.xValues = reconstructedSignal.xValues/samplingFreq;

%% Plotting
figure;
ax = zeros(12);
for i = 1:10
    ax(i) = subplot(12,1,i);
    plot(reconstructedSignal.xValues, reconstructedSignal.yValues(i,1:end));
    hold on;
end

ax(11) = subplot(12,1,11);
plot(reconstructedSignal.xValues, extractedData.data(1:end,11));
ylim([0 255]);
hold on;

ax(12) = subplot(12,1,12);
plot(reconstructedSignal.xValues, extractedData.data(1:end,12));
ylim([0 250]);
hold on;
linkaxes(ax, 'x');

%% Distance between sync pulses and peaks
distance = findFirstPeaks(extractedData, reconstructedSignal);
