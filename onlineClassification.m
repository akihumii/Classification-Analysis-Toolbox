function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

[files,path,iters] = selectFiles('Select trained parameters...');

classifierParameters = load(fullfile(path,files{1,1}));
classifierParameters = classifierParameters.varargin{1,1};

numChannel = length(classifierParameters);

%% Initialization
ports = [1340,1341];

for i = 1:numChannel
    classInfo{i,1} = classOnlineClassification();
    
    setBasicParameters(classInfo{i,1},classifierParameters(i,1));
    setTcpip(classInfo{i,1},'127.0.0.1',ports(1,i),'NetworkRole','client');
end

%% Streaming data
for i = 1:numChannel % open the port
    t(i,1) = tcpip(classInfo{i,1});
%     fopen(t(i,1));
    disp(['Open port ',num2str(ports(1,i)),'...']);
end

while(1)
    for i = 1:numChannel
        readSample(classInfo,t);
        detectBurst(classInfo);
        classifyBurst(classInfo);
    end
end

fclose(t);

end

