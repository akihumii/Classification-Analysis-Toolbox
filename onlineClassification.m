function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

[files,path] = selectFiles('Select trained parameters...');

classifierParameters = load(fullfile(path,files{1,1}));
classifierParameters = classifierParameters.varargin{1,1};

%% Initialization
ports = [1340,1341];

classInfo = classOnlineClassification();

setBasicParameters(classInfo,classifierParameters);
setTcpip(classInfo,'127.0.0.1',ports,'NetworkRole','client');
setInitialData(classInfo);

%% Streaming data
tcpip(classInfo);
openPort(obj);

while(1)
    readSample(classInfo);
    detectBurst(classInfo);
    classifyBurst(classInfo);
end

closePort(obj);

end

