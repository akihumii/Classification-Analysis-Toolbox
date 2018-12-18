function [] = onlineClassification()
%ONLINECLASSIFIER Do the online classification in the Qt after reading the
%prameters saved by onlineClassifierTraining
%   Detailed explanation goes here

close hidden all

warning('off','all');

global startAllFlag
global stopFlag
global openPortFlag
global tNumber
global tStatus
global buttonStartStop
global stopAll
global toggleInterval
% global stimulationDuration

startAllFlag = 0;
stopFlag = 1;
openPortFlag = 0;
stopAll = 0;
currentElapsedTime = 0;

dispPredictionDialog();
drawnow

while ~stopAll 
    if startAllFlag
        try
            if ~stopFlag && ~openPortFlag
                %% Parameters
                parameters = struct('replyPort',1300,'channelEnable',251,'numChannel',4);
                
                % open reply port
                try
                    tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client','Timeout',1);
                    disp(['Opened port ',num2str(parameters.channelEnable),' as reply port...'])
                catch
                    disp(['Reply port ',num2str(parameters.channelEnable),' is not open yet...'])
                end
                
                fopen(tB);
                
                %%  Run the online classification
                % Initialization
                stimulationCh = zeros(1, parameters.numChannel);
                openPortFlag = 1;
                pair = 1;
                currentElapsedTime = 0; % seconds
                
            elseif ~stopFlag && openPortFlag
                % Send stimulation
                startingTime = tic;
                switch pair % pair channels stimulation 
                    case 1 % stimulate channel 1 & 3
                        stimulationCh = [0,1,0,1];
                        pair = 2;
                        
                    case 2 % stimulate channel 2 & 4
                        stimulationCh = [1,0,1,0];
                        pair = 1;
                        
                    otherwise
                end
                
                replyPredictionDec = bi2de(stimulationCh,'left-msb');
                fwrite(tB,[parameters.channelEnable,replyPredictionDec]); % to enable the channel
                tNumber.String = num2str(stimulationCh);
                drawnow
            
                stopTime = toc(startingTime);
                
                pause(toggleInterval - stopTime)
                
                currentElapsedTime = currentElapsedTime + toggleInterval;

%                 if currentElapsedTime > stimulationDuration
%                     tNumber.String = num2str([0,0,0,0]);
%                     stimulationCh = [0,0,0,0];
%                     replyPredictionDec = bi2de(stimulationCh,'left-msb');
%                     fwrite(tB,[parameters.channelEnable,replyPredictionDec]); % to enable the channel
%                     tStatus.String = 'Program stopped...';
%                     buttonStartStop.String = 'Start';
%                     buttonStartStop.ForegroundColor = [0,190/256,0];
%                     stopFlag = 1;
%                     openPortFlag = 0;
%                     drawnow
%                 end
            else
                openPortFlag = 0;
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

