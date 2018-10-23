function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

% [files,path] = selectFiles('Select trained parameters...');
% 
% classifierParameters = load(fullfile(path,files{1,1}));

warning('off','all');

%% Parameters
parameters = struct(...
    'overlapWindowSize',50);

classifierParameters = load('C:\Users\lsilsc\Desktop\OnlineClassificationInfo_20181023113558_3.mat');
classifierParameters = classifierParameters.varargin{1,1};

%% Initialization
ports = [1345,1346];

classInfo = classOnlineClassification();

setBasicParameters(classInfo,classifierParameters,parameters);
setTcpip(classInfo,'127.0.0.1',ports,'NetworkRole','client');
setInitialData(classInfo);

%% Streaming data
tcpip(classInfo);
openPort(classInfo);

i=1;
while(1)
    readSample(classInfo);
%     t = tic;
    detectBurst(classInfo);
    classifyBurst(classInfo);
%     toc(t)
% i = i+1
end

closePort(classInfo);

end

