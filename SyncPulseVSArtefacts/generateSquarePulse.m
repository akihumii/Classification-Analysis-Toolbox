function output = generateSquarePulse(dataRef, samplingFreqOriginal)
%GENERATESQUAREPULSE Lijing Square Pulse Stimulator
% input:    dataRef: column 1: Check the timing of each starting point
%                    column 2: The data to refer for the square wave amplitude
% 
%   [squareWaveTime,squareWave] = generateSquarePulse(signal)

%% Parameters
% General parameters
pulsePeriod = 1/50; % seconds
pulseDuration = 200e-6; % seconds
intraGap = 22e-6; % seconds
interPulseFromDiffChannelDelay = 0.71e-3; % seconds
constantConversion = [-.0087, 13.383, -7.58];

samplingFreq = 1e4; % Hz, for more detailed simulation catering for the short pulseDuration, which is shorter than the original sampling frequency

showPlot = 1;

%% Main
chStartingRef = [16,17,18,19]; % values in sync pulse to indicate the start and end of the channel 
numChannel = length(chStartingRef); 

numSamplePoints = size(dataRef,1); % length of the signal in sample points

%% get starting timing and end timing
clear chLocs chStartingPoint chEndPoint numStartingPoint squareWave lengthSW SWTemp

for i = 1:numChannel
    preLocs = find(dataRef(:,1) == chStartingRef(i));
    preLocsDiff = diff(preLocs);
    chLocs{i,1} = preLocs([true;preLocsDiff~=1]);
end
chLocs = cell2nanMat(chLocs);

for i = 1:numChannel
    chLocs(isnan(chLocs(:,i)),i) = chLocs(find(~isnan(chLocs(:,i)),1,'last'),i);
end
    
    
endLocs = reshape((dataRef(chLocs,2)==0),size(chLocs));
endLocsAny = any(endLocs,2); % for reference to see if any of the channel changed to zero

chStartingPoint = chLocs;
chEndPoint = chLocs(endLocsAny,:);

numStartingPoint = size(chStartingPoint,1);

%% tilt the starting points so that the pulses won't overlap
samplingFreqRatio = samplingFreq/samplingFreqOriginal; % new sampling frequency / original sampling frequency

chStartingPoint = chStartingPoint * samplingFreqRatio; % up sample the chStartingPoint and chEndPoint so that the minor delay can be seen
chEndPoint = chEndPoint * samplingFreqRatio;

lengthFullPulse = floor((2*pulseDuration + intraGap) * samplingFreq); % units: sample point
chStartingPointEdited(:,1) = chStartingPoint(:,1);
chEndPointEdited(:,1) = chEndPoint(:,1);

for i = 2:numChannel
    chStartingPointEdited(:,i) = chStartingPoint(:,i) + (i-1)*interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
    chEndPointEdited(:,i) = chEndPoint(:,i) + (i-1)*interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
end

%% Generate square wave
squareWave = zeros(numSamplePoints*samplingFreqRatio,numChannel);
squareWaveTime = 1/samplingFreq:1/samplingFreq:size(squareWave,1)/samplingFreq; % in seconds

for i = 1:numChannel
    for j = 1:numStartingPoint
        try
            chStartingPointEditedNext = chStartingPointEdited(j+1,i); % try getting the next starting point
        catch
            chStartingPointEditedNext = chStartingPointEdited(end,i); % otherwise get the last end point
        end
        lengthSW = (chStartingPointEditedNext - chStartingPointEdited(j,i)); % length of simulated square wave (in simulated sampling frequency)
        amplitudeTemp = dataRef(floor(chStartingPointEdited(j,i)/samplingFreqRatio),2);
        if amplitudeTemp
            constantConversionTemp = constantConversion;
            constantConversionTemp(3) = constantConversionTemp(3)-amplitudeTemp;
            rootTemp = roots(constantConversionTemp);
            rootTemp = round(rootTemp(rootTemp>0 & rootTemp<19)); % get the correct one
        else
            rootTemp = amplitudeTemp; % if the channel is off
        end
        SWTemp = stimulateSquareWave(floor(lengthSW),floor(pulsePeriod*samplingFreq),floor(pulseDuration*samplingFreq),rootTemp,floor(intraGap*samplingFreq));
        dataTemp = transpose(floor(chStartingPointEdited(j,i)) : floor(chStartingPointEditedNext));
        dataTemp = dataTemp(1:length(SWTemp));
        squareWave(dataTemp,i) = SWTemp;
    end
end

%% Output
output.squareWaveTime = squareWaveTime;
output.squareWave = squareWave;
output.chStartingPoint = chStartingPoint;
output.chEndPoint = chEndPoint;
output.chStartingTime = chStartingPoint/samplingFreq;
output.chEndTime = chEndPoint/samplingFreq;
output.samplingFreq = samplingFreq;
output.showPlot = showPlot;

end

