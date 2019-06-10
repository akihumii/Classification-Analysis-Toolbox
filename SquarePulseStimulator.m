%% Lijing Square Pulse Stimulator
% Run mainClassifier to get the data first :)

clearvars -except signal

%% Parameters
pulsePeriod = 1/50; % seconds
pulseDuration = 200e-6; % seconds
amplitude = 10;
intraGap = 10e-6; % seconds

coeff = [0.0052, 12.885, 7.0055];  % coefficients to convert the amplitude back from byte form

samplingFreq = 1e4; % Hz

%% Main
dataAddress = signal.dataAll(:,13);  % check the timing of each starting point.
dataValue = signal.dataAll(:,14);  % the value of the command

% chStartingRef = [16,17,18,19]; % values in sync pulse to indicate the start and end of the channel 
chStartingRef = [241, 242, 243, 244]; % values in sync pulse to indicate the start and end of the channel 
numChannel = length(chStartingRef); 

numSamplePoints = size(dataAddress,1); % length of the signal in sample points

%% get starting timing and end timing
clear chLocs chStartingPoint chEndPoint numStartingPoint squareWave lengthSW SWTemp

for i = 1:numChannel
    preLocs = find(dataAddress == chStartingRef(i));
    preLocsDiff = diff(preLocs);
    chLocs{i,1} = preLocs([true;preLocsDiff~=1]);
%     chLocs(:,i) = preLocs([true;preLocsDiff~=1]);
    changeLocs = dataValue(chLocs{i,1}) ~= 0;
    chStartingPoint{i,1} = chLocs{i,1}(changeLocs);
    chEndPoint{i,1} = chLocs{i,1}([false; changeLocs(1:end-1)]);
end

numStartingPoint = size(chStartingPoint{1,1},1);


%% Generate square wave
samplingFreqRatio = samplingFreq/signal.samplingFreq; % new sampling frequency / original sampling frequency

squareWave = zeros(numSamplePoints*samplingFreqRatio,numChannel);
squareWaveTime = 1/samplingFreq : 1/samplingFreq : size(squareWave,1)/samplingFreq; % in seconds

for i = 1:numChannel
    for j = 1:numStartingPoint
        lengthSW = (chEndPoint{i,1}(j,1) - chStartingPoint{i,1}(j,1))*samplingFreqRatio; % length of simulated square wave (in simulated sampling frequency)
        coeff(3) = coeff(3) - dataValue(chStartingPoint{i,1}(j,1));
        amplitudeTemp = roots(coeff);
        amplitudeTemp = amplitudeTemp(amplitudeTemp > 0);
        SWTemp = stimulateSquareWave(lengthSW,floor(pulsePeriod*samplingFreq),floor(pulseDuration*samplingFreq),amplitudeTemp,intraGap*samplingFreq);
        squareWave(transpose(chStartingPoint{i,1}(j,1)*samplingFreqRatio : chEndPoint{i,1}(j,1)*samplingFreqRatio-1),i) = SWTemp;
    end
end

plotFig(squareWaveTime,squareWave);








