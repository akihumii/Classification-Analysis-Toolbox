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
t = tcpip(classInfo);
%     fopen(t(i,1));
disp(['Open port ',num2str(ports),'...']);

while(1)
    readSample(classInfo,t);
    detectBurst(classInfo);
    classifyBurst(classInfo);
end

fclose(t);

end

