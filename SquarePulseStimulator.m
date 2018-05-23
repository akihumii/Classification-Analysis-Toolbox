%% Lijing Square Pulse Stimulator
% Run mainClassifier to get the data first :)

clearvars -except signal

%% Parameters
pulsePeriod = 1/50; % seconds
pulseDuration = 200e-6; % seconds
amplitude = 10;
intraGap = 10e-6; % seconds

samplingFreq = 1e4; % Hz

%% Main
dataRef = signal.dataAll(:,13); % check the timing of each starting point.

chStartingRef = [16,17,18,19]; % values in sync pulse to indicate the start and end of the channel 
numChannel = length(chStartingRef); 

numSamplePoints = size(dataRef,1); % length of the signal in sample points

%% get starting timing and end timing
clear chLocs chStartingPoint chEndPoint numStartingPoint squareWave lengthSW SWTemp

for i = 1:numChannel
    preLocs = find(dataRef == chStartingRef(i));
    preLocsDiff = diff(preLocs);
    chLocs(:,i) = preLocs([true;preLocsDiff~=1]);
end

chStartingPoint = chLocs(1:2:size(chLocs,1),:);
chEndPoint = chLocs(2:2:size(chLocs,1),:);

numStartingPoint = size(chStartingPoint,1);

%% Generate square wave
samplingFreqRatio = samplingFreq/signal.samplingFreq; % new sampling frequency / original sampling frequency

squareWave = zeros(numSamplePoints*samplingFreqRatio,numChannel);
squareWaveTime = 1/samplingFreq:1/samplingFreq:size(squareWave,1)/samplingFreq; % in seconds

for i = 1:numChannel
    for j = 1:numStartingPoint
        lengthSW = (chEndPoint(j,i) - chStartingPoint(j,i))*samplingFreqRatio; % length of simulated square wave (in simulated sampling frequency)
        SWTemp = stimulateSquareWave(lengthSW,floor(pulsePeriod*samplingFreq),floor(pulseDuration*samplingFreq),amplitude,intraGap*samplingFreq);
        squareWave(transpose(chStartingPoint(j,i)*samplingFreqRatio : chEndPoint(j,i)*samplingFreqRatio-1),i) = SWTemp;
    end
end

plotFig(squareWaveTime,squareWave);








