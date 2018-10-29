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
    'overlapWindowSize',50,...
    'numChannel',length(classifierParameters),...
    'ports',[1343,1344,1345,1346],...
    'replyPort',1300);
%     'ports',[1345,1346]);

for i = 1:parameters.numChannel
    classInfo{i,1} = classOnlineClassification();
    
    setBasicParameters(classInfo{i,1},classifierParameters{i,1},parameters);
    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client');
    
    % Streaming data
    tcpip(classInfo{i,1});
    openPort(classInfo{i,1});
end

% open reply port
tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client');
% fopen(tB);

%%  Run the online classification
clearvars -except parameters classInfo

elapsedTime = cell(parameters.numChannel,1);
predictClassAll = zeros(1, parameters.numChannel);
sentPredictClassFlag = 0;

c = 1;
maxC = 1000;

for i = 1:parameters.numChannel
    p(i,1) = figure;
    h(i,1) = gca;
end

while c < maxC
    
    for i = 1:parameters.numChannel
        readSample(classInfo{i,1});
        t = tic;
%         plot(h(i,1),classInfo{i,1}.dataFiltered)
%         pause(0.0001)
        detectBurst(classInfo{i,1});
        classifyBurst(classInfo{i,1});
        
        if predictClassAll(1,i) ~= classInfo{i,1}.predictClass % update if state changed
            sentPredictClassFlag = 1;
            predictClassAll(1,i) = classInfo{i,1}.predictClass;
        end
        
%         if i == 1
%             disp(['Class ',num2str(i),' prediction: ',num2str(classInfo{i,1}.predictClass)]);
            elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
%         end
    end
    
    if sentPredictClassFlag
        replyPrediction = bi2de(predictClassAll,'left-msb')
%         fwrite(tB,replyPrediction);
        sentPredictClassFlag = 0; % reset sending predicted class flag
    end

    c = c+1;
end

% closePort(classInfo);

end

