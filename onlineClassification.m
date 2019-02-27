function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

close hidden all

warning('off','all');

[~, hGUI] = onlineClassificationGUI();
% dispPredictionDialog();
drawnow

predictionMethod = 'SimpleThresholding';  % either 'Features' or 'SimpleThresholding'

while ~hGUI.UserData.stopAll
    if hGUI.UserData.startAllFlag
        try
            if ~hGUI.UserData.stopFlag && ~hGUI.UserData.openPortFlag
                %% Parameters
                parameters = struct(...
                    'overlapWindowSize',50,... % ms
                    'ports',[1343,1344,1345,1346],...
                    'replyPort',1300,...
                    'channelEnable',251,...
                    'numChannel',length(hGUI.UserData.classifierParameters));
                
                for i = 1:parameters.numChannel
                    classInfo{i,1} = classOnlineClassification(); % Initiatialize the object
                    
                    setBasicParameters(classInfo{i,1},hGUI.UserData.classifierParameters{i,1},parameters,predictionMethod);
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
                
                hGUI.UserData.openPortFlag = 1;
                % c = 1;
                % maxC = inf;
                
                % for i = 1:parameters.numChannel
                %     p(i,1) = figure;
                %     h(i,1) = gca;
                % end
            elseif ~hGUI.UserData.stopFlag && hGUI.UserData.openPortFlag
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
                        hGUI.dispPrediction.String = num2str(predictClassAll);
                        replyPredictionDec = bi2de(predictClassAll,'left-msb');
                        fwrite(tB,[parameters.channelEnable,replyPredictionDec]); % to enable the channel
                        drawnow
                    end
                    
                    %             disp(['Class ',num2str(i),' prediction: ',num2str(classInfo{i,1}.predictClass)]);
                    %             elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
                end
            else
                hGUI.UserData.openPortFlag = 0;
                %     c = c+1;
            end
        catch
            hGUI.UserData.startAllFlag = 0;
            hGUI.dispPrediction.String = num2str([0,0,0,0]);
            hGUI.dispStatus.String = 'Program stopped...';
            hGUI.buttonStartStop.String = 'Start';
            hGUI.buttonStartStop.ForegroundColor = [0,190/256,0];
            hGUI.UserData.stopFlag = 1;
            hGUI.UserData.openPortFlag = 0;
            popMsg('Wrong selection, please start over...');
            drawnow
        end
    end
    drawnow
end
end

