%% analyzeSylphX

clear 
close all
clc

%% Variable to be changed
% Hardware variable
samplingFreq = 1800;        % Sampling Frequency
voltageStep = 0.000000195;  % Sylph's voltage step

numChannel = 2; % number of channel

period = 1/samplingFreq;

extractedData = loadData('csv'); % input 'tdms' or 'csv' for different type of files

reconstructedSignal.yValues = zeros(numChannel, size(extractedData.data,1));

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
deletePairs = [];
distance = findFirstPeaks(extractedData, reconstructedSignal, deletePairs);
