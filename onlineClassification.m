function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

close hidden all

warning('off','all');

global startAllFlag
global stopFlag
global openPortFlag
global classifierParameters
global tNumber
global tStatus
global buttonStartStop
global stopAll

startAllFlag = 0;
stopFlag = 1;
openPortFlag = 0;
stopAll = 0;

dispPredictionDialog();
drawnow

while ~stopAll
    if startAllFlag
        try
            if ~stopFlag && ~openPortFlag
                %% Parameters
                parameters = struct(...
                    'overlapWindowSize',50,... % ms
                    'ports',[1343,1344,1345,1346],...
                    'replyPort',1300,...
                    'channelEnable',251,...
                    'numChannel',length(classifierParameters));
                
                for i = 1:parameters.numChannel
                    classInfo{i,1} = classOnlineClassification(); % Initiatialize the object
                    
                    setBasicParameters(classInfo{i,1},classifierParameters{i,1},parameters);
                    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client','Timeout',1);
                    
                    % Streaming data
                    tcpip(classInfo{i,1}); % open channel port
                    openPort(classInfo{i,1});
                end
                
                % open reply port
                try
                    tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client','Timeout',1);
                    disp(['Opened port ',num2str(parameters.channelEnable),' as reply port...'])
                catch
                    disp(['Reply port ',num2str(parameters.channelEnable),' is not open yet...'])
                end
                
                fopen(tB);
                
                %%  Run the online classification
                %     clearvars -except parameters classInfo tB
                
                % elapsedTime = cell(parameters.numChannel,1);
                predictClassAll = zeros(1, parameters.numChannel);
                
                openPortFlag = 1;
                % c = 1;
                % maxC = inf;
                
                % for i = 1:parameters.numChannel
                %     p(i,1) = figure;
                %     h(i,1) = gca;
                % end
            elseif ~stopFlag && openPortFlag
                %     msgBoxFig = msgbox('Prediction Class: 0 0 0 0...');
                
                for i = 1:parameters.numChannel
                    readSample(classInfo{i,1});
                    %         t = tic;
                    
                    %         plot(h(i,1),classInfo{i,1}.dataFiltered)
                    %         pause(0.0001)
                    %             detectBurst(classInfo{i,1});
                    classifyBurst(classInfo{i,1});
                    
                    if predictClassAll(1,i) ~= classInfo{i,1}.predictClass % update if state changed
                        predictClassAll(1,i) = classInfo{i,1}.predictClass;
                        switch i % check if conflict
                            case 2
                                predictClassAll(1,2) = predictClassAll(1,2) && ~predictClassAll(1,1);
                            case 4
                                predictClassAll(1,4) = predictClassAll(1,4) && ~predictClassAll(1,3);
                            otherwise
                        end
                        tNumber.String = num2str(predictClassAll);
                        replyPredictionDec = bi2de(predictClassAll,'left-msb');
                        fwrite(tB,[parameters.channelEnable,replyPredictionDec]); % to enable the channel
                        drawnow
                    end
                    
                    %             disp(['Class ',num2str(i),' prediction: ',num2str(classInfo{i,1}.predictClass)]);
                    %             elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
                end
            else
                openPortFlag = 0;
                %     c = c+1;
            end
        catch
            startAllFlag = 0;
            tNumber.String = num2str([0,0,0,0]);
            tStatus.String = 'Program stopped...';
            buttonStartStop.String = 'Start';
            buttonStartStop.ForegroundColor = [0,190/256,0];
            stopFlag = 1;
            openPortFlag = 0;
            popMsg('Wrong selection, please start over...');
            drawnow
        end
    end
    drawnow
end
end

