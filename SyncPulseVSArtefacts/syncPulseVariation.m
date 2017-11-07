clear all
close all
clc

% Variable to be changed

% Hardware variable
samplingFreq = 1100;        % Sampling Frequency
voltageStep = 0.000000195;  % Sylph's voltage step

period = 1/samplingFreq;

extractedData = loadData();

syncPulse.yAxis = extractedData.data(1:end,11);
syncPulse.xAxis = 0:size(syncPulse.yAxis)-1;
syncPulse.xAxis = syncPulse.xAxis/samplingFreq;

plot(syncPulse.xAxis, syncPulse.yAxis);

timeStampRaw = {};
timeStamp = {};

for j = 1:size(syncPulse.yAxis)
    if eq(syncPulse.yAxis(j,1), 255)
        timeStampRaw = [timeStampRaw, j];
        timeStamp = [timeStamp, j*period];
    end
end

variation = {};
lag = false;

for i = 1:(size(timeStampRaw, 2) - 1)
    if(gt(max(syncPulse.yAxis(cell2mat(timeStampRaw(1, i))+1 : cell2mat(timeStampRaw(1, i+1))-1 , 1) ), 0))
        fprintf('Data between %d and %d is laggy \n', i, i+1);
    else
        variation = [variation, (cell2mat(timeStamp(1, i+1))-cell2mat(timeStamp(1, i)))];
    end
end

disp(variation);

% variation(4) = [];

max = max(cell2mat(variation));

mean = mean(cell2mat(variation));

min = min(cell2mat(variation));

largestVariation = (max - min);

disp(timeStamp);
