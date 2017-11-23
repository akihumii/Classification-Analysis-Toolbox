%% Elaine

clear 
close all
clc

%% Variable to be changed
% Hardware variable
samplingFreq = 128;        % Sampling Frequency
voltageStep = 0;  % Sylph's voltage step

period = 1/samplingFreq;

extractedData = loadData();

reconstructedSignal.yValues = zeros(3, size(extractedData.data(1:end,1), 1));

for i = 1:3
    reconstructedSignal.yValues(i,:) = transpose(extractedData.data(:,i));
end

reconstructedSignal.xValues = 0:size(extractedData.data(1:end,1), 1)-1;
reconstructedSignal.xValues = reconstructedSignal.xValues/samplingFreq;

%% Plotting
figure;
ax = zeros(3);
for i = 1:3
    ax(i) = subplot(3,1,i);
    plot(reconstructedSignal.xValues, reconstructedSignal.yValues(i,1:end));
    hold on;
end

%% Distance between sync pulses and peaks
deletePairs = [];
info = findFirstPeaks(extractedData, reconstructedSignal, deletePairs);

disp('Finished...')



