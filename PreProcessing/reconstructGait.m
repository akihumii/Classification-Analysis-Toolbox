function [data,xAxisValues] = reconstructGait(gaitLocsRaw,timeRaw,dataRaw)
%reconstructGait Reconstruct data into overlapped window according to the
%starting stance lines
%   Detailed explanation goes here

samplingFreq = 1 / (timeRaw(1,2)-timeRaw(1,1));

if timeRaw(1) > 0
    time = timeRaw-timeRaw(1) + 1/samplingFreq; % initialize the time array
end

%% get useful gait locs
gaitLocsRaw = gaitLocsRaw';

gaitLocsTemp = gaitLocsRaw>time(1) & gaitLocsRaw<time(end); % trim by size

gaitLocsTemp = and(gaitLocsTemp(:,1)==1 , gaitLocsTemp(:,2)); % trim by pair

gaitLocsTemp = gaitLocsRaw(repmat(gaitLocsTemp,1,2)); % get locs
gaitLocs = reshape(gaitLocsTemp,[],2); % put into two columns

gaitLocs =  floor(gaitLocs * samplingFreq);
time = floor(time * samplingFreq);

if timeRaw(1) <= 0
    gaitLocs = gaitLocs - time(1,1) + 1; % initialize gait locations according to first timestamp
    time = time - time(1,1) + 1; % initialize time according to first timestamp
end

%% reconstruct data
gaitLocs = [time(1,1),time(1,1);gaitLocs];

numGaitLocs = size(gaitLocs,1);

for i = 2:numGaitLocs
    zeroLocsTemp = gaitLocs(i,1); % zero point is at starting stance line
    startingLocsTemp = gaitLocs(i-1,2); % starting point is at previous end stance line
    endLocsTemp = gaitLocs(i,2); % end point is at current end stance line
    data{i-1,1} = transpose(dataRaw(startingLocsTemp:endLocsTemp));
    xAxisValues{i-1,1} = transpose(((startingLocsTemp:endLocsTemp) - zeroLocsTemp) / samplingFreq); % in seconds    
end

data = cell2nanMat(data);
xAxisValues = cell2nanMat(xAxisValues);

end

