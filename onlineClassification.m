function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

% [files,path] = selectFiles('Select trained parameters...');
% 
% classifierParameters = load(fullfile(path,files{1,1}));

warning('off','all');

%classifierParameters = load('C:\Users\lsilsc\Desktop\OnlineClassificationInfo_20181023113558_3.mat');
[files,path] = selectFiles('Select trained parameters...');

classifierParameters = load(fullfile(path,files{1,1}));
classifierParameters = classifierParameters.varargin{1,1};

%% Parameters
parameters = struct(...
    'overlapWindowSize',50,...
    'numChannel',length(classifierParameters),...
    'ports',[1345,1346]);

for i = 1:parameters.numChannel
    classInfo{i,1} = classOnlineClassification();
    
    setBasicParameters(classInfo{i,1},classifierParameters{i,1},parameters);
    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client');
%     setInitialData(classInfo{i,1});
    
    %% Streaming data
    tcpip(classInfo{i,1});
    openPort(classInfo{i,1});
end

while(1)
    for i = 1:parameters.numChannel
        readSample(classInfo{i,1});
            t = tic;
        detectBurst(classInfo{i,1});
        classifyBurst(classInfo{i,1});
        
        if classInfo{i,1}.readyClassify
%             disp(['Class ',num2str(i),' prediction: ',num2str(classInfo{i,1}.predictClass)]);
            classInfo{i,1}.readyClassify = 0; % to deactivate the readyClassify after the prediction
        end
            toc(t)
    end
end

closePort(classInfo);

end

