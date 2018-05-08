function output = generateSquarePulse(dataRef, samplingFreqOriginal)
%GENERATESQUAREPULSE Lijing Square Pulse Stimulator
% input:    dataRef: Check the timing of each starting point
% 
%   [squareWaveTime,squareWave] = generateSquarePulse(signal)

%% Parameters
% General parameters
pulsePeriod = 1/50; % seconds
pulseDuration = 200e-6; % seconds
amplitude = 10;
intraGap = 10e-6; % seconds
interPulseFromDiffChannelDelay = 0.71e-3; % seconds

samplingFreq = 1e5; % Hz, for more detailed simulation catering for the short pulseDuration, which is shorter than the original sampling frequency

%% Main
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

%% tilt the starting points so that the pulses won't overlap
samplingFreqRatio = samplingFreq/samplingFreqOriginal; % new sampling frequency / original sampling frequency

chStartingPoint = chStartingPoint * samplingFreqRatio; % up sample the chStartingPoint and chEndPoint so that the minor delay can be seen
chEndPoint = chEndPoint * samplingFreqRatio;

lengthFullPulse = (2*pulseDuration + intraGap) * samplingFreq; % units: sample point

for i = 2:numChannel
    chStartingPoint(:,i) = chStartingPoint(:,i) + (i-1)*interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
    chEndPoint(:,i) = chEndPoint(:,i) + (i-1)*interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
end

%% Generate square wave
squareWave = zeros(numSamplePoints*samplingFreqRatio,numChannel);
squareWaveTime = 1/samplingFreq:1/samplingFreq:size(squareWave,1)/samplingFreq; % in seconds

for i = 1:numChannel
    for j = 1:numStartingPoint
        lengthSW = (chEndPoint(j,i) - chStartingPoint(j,i)); % length of simulated square wave (in simulated sampling frequency)
        SWTemp = stimulateSquareWave(lengthSW,floor(pulsePeriod*samplingFreq),floor(pulseDuration*samplingFreq),amplitude,intraGap*samplingFreq);
        squareWave(transpose(chStartingPoint(j,i) : chEndPoint(j,i)-1),i) = SWTemp;
    end
end

%% Output
output.squareWaveTime = squareWaveTime;
output.squareWave = squareWave;
output.chStartingPoint = chStartingPoint;
output.chEndPoint = chEndPoint;
output.samplingFreq = samplingFreq;

end

