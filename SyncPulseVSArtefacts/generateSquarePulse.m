function output = generateSquarePulse(dataRef, samplingFreqOriginal,odinparam)
%GENERATESQUAREPULSE Lijing Square Pulse Stimulator
% input:    dataRef: column 1: Check the timing of each starting point
%                    column 2: The data to refer for the square wave amplitude
%                    column 3: Get the amplitude
%           odinparam.chStartingRef: values in sync pulse to indicate the start and end of the channel 
% 
%   [squareWaveTime,squareWave] = generateSquarePulse(signal)

%% Parameters
% General parameters
samplingFreq = 1e4; % Hz, for more detailed simulation catering for the short odinparam.pulseDuration, which is shorter than the original sampling frequency

%% Main
numChannel = length(odinparam.chStartingRef); 

numSamplePoints = size(dataRef,1); % length of the signal in sample points

%% get starting timing and end timing
clear chLocs chStartingPoint chEndPoint numStartingPoint squareWave lengthSW SWTemp

for i = 1:numChannel
    preLocs = find(dataRef(:,1) == odinparam.chStartingRef(i));  % find starting point of stimulation for electrodes channels in channel 13
    preLocsDiff = diff(preLocs);
    if ~isempty(preLocsDiff)
        chLocs{i,1} = preLocs([true;preLocsDiff~=1]);
    else
        warning(sprintf('Couldn''t find %d...', odinparam.chStartingRef(i)));
        chLocs{i,1} = [];
    end
    
    preLocs = find(dataRef(:,2) == 0);  % find 0 in channel 14 == stop stimulation
    preLocsDiff = diff(preLocs);
    if ~isempty(preLocsDiff)
        chLocs{i,1} = [chLocs{i,1}; preLocs([true;preLocsDiff~=1])];
    else
        warning(sprintf('Couldn''t find %d...', odinparam.chStartingRef(i)));
        chLocs{i,1} = chLocs{i,1};
    end

end
chLocs = cell2nanMat(chLocs);

for i = 1:numChannel
    locTemp = chLocs(find(~isnan(chLocs(:,i)),1,'last'),i);
    if ~isempty(locTemp)
        chLocs(isnan(chLocs(:,i)),i) = locTemp;
    else
        chLocs(isnan(chLocs(:,i)),i) = 1;
    end
end
    
    
endLocs = reshape((dataRef(chLocs,2)==0),size(chLocs));
if ~isempty(chLocs) % hack job for coudln't find anything in all channels
    endLocs(1,end) = 1;  % hack job cos it looks like it's always in this case XO
end
endLocsAny = any(endLocs,2); % for reference to see if any of the channel changed to zero

chStartingPoint = chLocs;
chEndPoint = chLocs(endLocsAny,:);

%% Add in more starting points by checking channel 15
for i = 1:numChannel
    changeLocs{i,1} = zeros(0,1);
    for j = 1:size(chStartingPoint,1)-1
%     for j = 1:2:size(chStartingPoint,1)
        diffTemp = diff(dataRef(chStartingPoint(j,1):chStartingPoint(j+1,1) , 3));
        changeLocs{i,1} = [changeLocs{i,1}; find(diffTemp ~= 0)];
        changeLocs{i,1} = changeLocs{i,1} + chStartingPoint(j,1) - 1;
    end
end
changeLocs = cell2nanMat(changeLocs);

chStartingPointAll = vertcat(chStartingPoint,changeLocs);
chStartingPointAll = sort(chStartingPointAll);

%% tilt the starting points so that the pulses won't overlap
samplingFreqRatio = samplingFreq/samplingFreqOriginal; % new sampling frequency / original sampling frequency

chStartingPointAll = chStartingPointAll * samplingFreqRatio; % up sample the chStartingPoint and chEndPoint so that the minor delay can be seen
chStartingPoint = chStartingPoint * samplingFreqRatio;
changeLocs = changeLocs * samplingFreqRatio;

chEndPoint = chEndPoint * samplingFreqRatio;

lengthFullPulse = floor((2*odinparam.pulseDuration + odinparam.intraGap) * samplingFreq); % units: sample point
chStartingPointEdited(:,1) = chStartingPointAll(:,1);
chEndPointEdited(:,1) = chEndPoint(:,1);

for i = 2:numChannel
    chStartingPointEdited(:,i) = chStartingPointAll(:,i) + (i-1)*odinparam.interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
    chEndPointEdited(:,i) = chEndPoint(:,i) + (i-1)*odinparam.interPulseFromDiffChannelDelay*samplingFreq + (i-1)*lengthFullPulse;
end

%% Generate square wave
numStartingPoint = size(chStartingPointEdited,1);

squareWave = zeros(numSamplePoints*samplingFreqRatio,numChannel);
squareWaveTime = 1/samplingFreq:1/samplingFreq:size(squareWave,1)/samplingFreq; % in seconds

amplitude = zeros(0,1);

for j = 1:numStartingPoint
    if ~ismember(chStartingPointEdited(j,i),chEndPointEdited(:,i))
        amplitudeTemp = dataRef(floor((chStartingPointEdited(j,1)+10)/samplingFreqRatio),3);
        if ismember(chStartingPointAll(j,1), changeLocs)
            amplitude = [amplitude; amplitudeTemp];
        end
        for i = 1:numChannel
            try
                chStartingPointEditedNext = chStartingPointEdited(j+1,i); % try getting the next starting point
            catch
                chStartingPointEditedNext = chEndPointEdited(end,i); % otherwise get the last end point
            end
            lengthSW = (chStartingPointEditedNext - chStartingPointEdited(j,i)); % length of simulated square wave (in simulated sampling frequency)
            
            %         amplitudeTemp = dataRef(floor(chStartingPointEdited(j,i)/samplingFreqRatio),2);
            %         if amplitudeTemp
            %             constantConversionTemp = odinparam.constantConversion;
            %             constantConversionTemp(3) = constantConversionTemp(3)-amplitudeTemp;
            %             rootTemp = roots(constantConversionTemp);
            %             amplitude(j,i) = round(rootTemp(rootTemp>0 & rootTemp<19)); % get the correct one
            %         else
            %             amplitude(j,i) = amplitudeTemp; % if the channel is off
            %         end
            
            SWTemp = stimulateSquareWave(floor(lengthSW),floor(odinparam.pulsePeriod*samplingFreq),floor(odinparam.pulseDuration*samplingFreq),amplitudeTemp,floor(odinparam.intraGap*samplingFreq));
            dataTemp = transpose(floor(chStartingPointEdited(j,i)) : floor(chStartingPointEditedNext));
            dataTemp = dataTemp(1:length(SWTemp));
            squareWave(dataTemp,i) = SWTemp;
        end
    end
end

%% Output
output.squareWaveTime = squareWaveTime;
output.squareWave = squareWave;
output.chStartingPoint = chStartingPoint;
output.changeLocs = changeLocs;
output.changeLocsTime = changeLocs/samplingFreq;
output.chEndPoint = chEndPoint;
output.chStartingTime = chStartingPoint/samplingFreq;
output.chEndTime = chEndPoint/samplingFreq;
output.amplitude = amplitude;
output.samplingFreq = samplingFreq;

end

