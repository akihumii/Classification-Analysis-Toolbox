clear all
close all
clc

% Variable to be changed
channel = 5;                % Channel to perform FFT
inputAmplitude = 0.00003;       % Amplitude of input signal

% Hardware variable
samplingFreq = 4196;        % Sampling Frequency
voltageStep = 0.000000195;  % Sylph's voltage step

extractedData = loadData();

rawData.yAxis = reconstructSignal(extractedData.data(7000:end,channel),0.000000195);
rawData.yAxis = rawData.yAxis - mean(rawData.yAxis);
rawData.xAxis = 0:size(rawData.yAxis)-1;
rawData.xAxis = rawData.xAxis/samplingFreq;

plot(rawData.xAxis,rawData.yAxis);

bandwidth = computeBandwidth(rawData.yAxis, samplingFreq);

windowSize = 100; 
b = (1/windowSize)*ones(1,windowSize);

% Plot normal scale dB graph (dB vs freq)
figure;
plot(bandwidth.xValue, filter(b,1,bandwidth.yValue)); 

% Plot logarithmic scale dB graph (dB vs freq)
figure;
semilogx(bandwidth.xValue, bandwidth.yValue);