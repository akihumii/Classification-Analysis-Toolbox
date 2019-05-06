function output = restoreSignal(spikeLocs, parameters, samplingFreq)
%RESTORESIGNAL Restore the signal by checking the distance between each
%locs
%   locsChosen = restoreSignal(spikeLocs, separation, parameters.restoreTolerance, samplingFreq)

%% Phase 1
locsChosen = getSpike(spikeLocs, parameters, samplingFreq);

%% Phase 2
[locsTrainStart, locsTrainStop] = getSpikeTrainStartStop(parameters, samplingFreq, locsChosen);

%% Phase 3
locsTrainMajor = getSpikeTrainMajor(parameters, samplingFreq, locsTrainStart, locsTrainStop);

%% Phase 4
locsTrainMinor = getSpikeTrainMinor(parameters, samplingFreq, locsTrainMajor);

% aa = gca;
% hold on
% data = aa.Children(3).YData;
% plot(c, data(c), 'rx');

%% Output
output = makeStruct(...
    locsChosen,...
    locsTrainStart,...
    locsTrainStop,...
    locsTrainMajor,...
    locsTrainMinor);

end

function locsTrainMinor = getSpikeTrainMinor(parameters, samplingFreq, locsTrainMajor)
    numCol = size(locsTrainMajor,2);
    for i = 1:numCol
        locsTrainMinor{i,1} = [];
        locsTempMajor = locsTrainMajor(~isnan(locsTrainMajor(:,i)),i);
        numStim = length(locsTempMajor);
        for j = 1:numStim
            locsTempMinor = floor(locsTempMajor(j,1) + (samplingFreq/parameters.restoreInterSpikeSeparation) : ...
                (samplingFreq/parameters.restoreInterSpikeSeparation) : ...
                locsTempMajor(j,1) + (parameters.restoreNumSpikes-1) * (samplingFreq/parameters.restoreInterSpikeSeparation));
            locsTrainMinor{i,1} = [locsTrainMinor{i,1}, locsTempMinor];
        end
        locsTrainMinor{i,1} = locsTrainMinor{i,1}';
    end
    
    locsTrainMinor = cell2nanMat(locsTrainMinor);
end

function locsTrainMajor = getSpikeTrainMajor(parameters, samplingFreq, locsTrainStart, locsTrainStop)
    [numStim, numCol] = size(locsTrainStart);

    locsTrainMajor = cell(numCol,1);

    for i = 1:numCol
        locsTrainMajor{i,1} = [];
        for j = 1:numStim
            startingPoint = locsTrainStart(j,i);
            endPoint = locsTrainStop(j,i);
            locsTemp = floor(startingPoint : ...
                (parameters.restoreNumSpikes-1) * ...
                (samplingFreq/parameters.restoreInterSpikeSeparation)+(samplingFreq/parameters.restoreInterTrainFrequency) : ...
                endPoint);
            locsTrainMajor{i,1} = [locsTrainMajor{i,1}, locsTemp];
        end
        locsTrainMajor{i,1} = locsTrainMajor{i,1}';
    end
    
    locsTrainMajor = cell2nanMat(locsTrainMajor);
end

function [locsTrainStart, locsTrainStop] = getSpikeTrainStartStop(parameters, samplingFreq, locsChosen)
    numCol = size(locsChosen,2);

    for i = 1:numCol
        locsDiff = diff(locsChosen(~isnan(locsChosen(:,i)),i));

        interTrainSeparationSamplePoint = parameters.restoreInterStimulationSeparation * samplingFreq;
        locsTrainFlag = locsDiff > interTrainSeparationSamplePoint;
        locsTrainStartFlag = [true; locsTrainFlag];
        locsTrainStopFlag = [locsTrainFlag; true];
        locsTrainStartFlagLocs = find(locsTrainStartFlag == 1);
        locsTrainStopFlagLocs = find(locsTrainStopFlag == 1);
        
        % check if the first spike has 6 detected spike in a row by
        % checking if the 5th point after that is within the range
        numSecuringPointStart = (parameters.restoreNumSpikes-2);
        for j = 1:length(locsTrainStartFlagLocs)
            locsTemp = locsTrainStartFlagLocs(j,1);
            % find the starting 
            while locsChosen(locsTemp+numSecuringPointStart,i) - locsChosen(locsTemp,i) > ...
                    (parameters.restoreNumSpikes-1) * (samplingFreq/parameters.restoreInterSpikeSeparation)...
                
                locsTrainStartFlag(locsTemp) = false;
                
                locsTemp = locsTemp + 1;                
            end
            locsTrainStartFlag(locsTemp) = true;
        end
        
        % find the end
        numSecuringPointStop = 2;
        for j = 1:length(locsTrainStopFlagLocs)
            locsTemp = locsTrainStopFlagLocs(j,1);
            while locsChosen(locsTemp,i) - locsChosen(locsTemp-numSecuringPointStop, i) > ...
                    (parameters.restoreNumSpikes-1) * (samplingFreq/parameters.restoreInterSpikeSeparation)...
                
                locsTrainStopFlag(locsTemp) = false;
                
                locsTemp = locsTemp - 1;                
            end
            locsTrainStopFlag(locsTemp) = true;
        end

        locsTrainStart{i,1} = locsChosen(locsTrainStartFlag, i);
        locsTrainStop{i,1} = locsChosen(locsTrainStopFlag, i);
    end

    locsTrainStart = cell2nanMat(locsTrainStart);
    locsTrainStop = cell2nanMat(locsTrainStop);
    
    numRowMin = min(size(locsTrainStart,1), size(locsTrainStop,1));
    locsTrainStart = locsTrainStart(1:numRowMin, :);
    locsTrainStop = locsTrainStop(1:numRowMin, :);
end

function locsChosen = getSpike(spikeLocs, parameters, samplingFreq)
    numCol = size(spikeLocs,2);

    locsDiff = diff(spikeLocs);  % distance between spikes

    interSpikeSeparationSamplePoint = 1/parameters.restoreInterSpikeSeparation * samplingFreq;  % convert into sample point unit
    toleranceSamplePoint = parameters.restoreTolerance * samplingFreq;

    boundaryLowerLimit = interSpikeSeparationSamplePoint - toleranceSamplePoint;  % get the boundary by using the parameters.restoreTolerance
    boundaryUpperLimit = interSpikeSeparationSamplePoint + toleranceSamplePoint;

    locsChosenFlag = locsDiff > boundaryLowerLimit & locsDiff < boundaryUpperLimit;  % get the spikes that has the separation within the boundary

    for i = 1:numCol
        locsChosen{i,1} = spikeLocs(locsChosenFlag(:,i), i);
    end
    locsChosen = cell2nanMat(locsChosen);
end

