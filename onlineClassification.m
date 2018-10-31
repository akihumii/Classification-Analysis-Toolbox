function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

close hidden all

warning('off','all');

% classifierParameters = load('C:\Users\lsitsai\Desktop\Derek\FTDI\Info\onlineClassification\OnlineClassificationInfo_20181026180040.mat');
[files,path] = selectFiles('Select trained parameters...');
classifierParameters = load(fullfile(path,files{1,1}));
classifierParameters = classifierParameters.varargin{1,1};

%% Parameters
parameters = struct(...
    'overlapWindowSize',50,... % ms
    'numChannel',length(classifierParameters),...
    'ports',[1343,1344,1345,1346],...
    'replyPort',1300,...
    'channelEnable',251);

for i = 1:parameters.numChannel
    classInfo{i,1} = classOnlineClassification();
    
    setBasicParameters(classInfo{i,1},classifierParameters{i,1},parameters);
    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client');
    
    % Streaming data
    tcpip(classInfo{i,1}); % open channel port
    openPort(classInfo{i,1});
end

% open reply port
try
    tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client');
    disp(['Opened port ',num2str(parameters.channelEnable),' as reply port...'])
catch
    disp(['Reply port ',num2str(parameters.channelEnable),' is not open yet...'])
end

fopen(tB);

%%  Run the online classification
clearvars -except parameters classInfo tB

% elapsedTime = cell(parameters.numChannel,1);
predictClassAll = zeros(1, parameters.numChannel);
sentPredictClassFlag = 0;

% c = 1;
% maxC = inf;

% for i = 1:parameters.numChannel
%     p(i,1) = figure;
%     h(i,1) = gca;
% end

while 1
    
    for i = 1:parameters.numChannel
        readSample(classInfo{i,1});
%         t = tic;

%         plot(h(i,1),classInfo{i,1}.dataFiltered)
%         pause(0.0001)
        detectBurst(classInfo{i,1});
        classifyBurst(classInfo{i,1});
        
        if predictClassAll(1,i) ~= classInfo{i,1}.predictClass % update if state changed
            sentPredictClassFlag = 1;
            predictClassAll(1,i) = classInfo{i,1}.predictClass;
        end
        
%             disp(['Class ',num2str(i),' prediction: ',num2str(classInfo{i,1}.predictClass)]);
%             elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
    end
    
    if sentPredictClassFlag
        replyPrediction = checkPrediction(predictClassAll);
        replyPrediction = bi2de(replyPrediction,'left-msb');
        fwrite(tB,[parameters.channelEnable,replyPrediction]); % to enable the channel
        sentPredictClassFlag = 0; % reset sending predicted class flag
    end

%     c = c+1;
end


end

