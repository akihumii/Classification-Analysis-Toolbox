% clear
% close all

%% Parameters
frequency = 50; % Hz
samplingFreq = 5000; % sampling frequency
totalDuration = 2; % second
numPulse = 1; % number of sin wave pulses
pulseFrequency = 10; % Hz
pulseDuration = 5; % second
amplitude = 5; % sinwave amplitude

%% Process
x = 1/samplingFreq:1/samplingFreq:totalDuration; % array of timestamps 
y = amplitude * sin(2*pi*frequency*x); % array of sin wave

envelopLocs = zeros(1,length(x));

for i = 1:numPulse
    envelopLocs((i-1)*((1/pulseFrequency)*samplingFreq) + 1 :...
        (i-1)*((1/pulseFrequency)*samplingFreq) + pulseDuration*samplingFreq + 1) = 1; % locations of needed sin wave values
end

envelopLocs = logical(envelopLocs); % convert into logicals

y(~envelopLocs) = 0; % eliminate unselected values

x = x'; % making it a tall vector
y = y';
%% FFT
[dataFFT, fqDomain] = fftDataConvert(y,samplingFreq);

%% Plotting
figure
plot(x,y) % plot raw sin wave with envelop
xlabel('Time(s)')

figure
plot(fqDomain, dataFFT) % plot FFT
title('FFT')
xlabel('Frequency')

