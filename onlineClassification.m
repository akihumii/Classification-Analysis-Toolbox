function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

[files,path,iters] = selectFiles('Select trained parameters...');

load(fullfile(path,files{1,1}));

%% Parameters


clear varargin files path

%% Initialization
rawData = zeros(0,1);

%% Streaming data
t = tcpip('127.0.0.1',1345,'NetworkRole','client');

fopen(t);

while(1)
    sample = fread(t, t.ByesAvailable);
    lengthData = length(rawData); % length of stored data
    if lengthData < parameters.lenTKEO
        rawData = [rawData; sample]; % accumulate samples at the beginning
    else
        if lengthData > parameters.maxBurstLength % to fix the burst length for processing
            rawData = [rawData(2:end); sample];
        end
        
        dataTKEO = TKEO(rawData,samplingFreq);
        
    end
end

fclose(t);

end

