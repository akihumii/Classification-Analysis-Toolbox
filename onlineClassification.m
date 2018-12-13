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
global stimulationDuration
global pair

startAllFlag = 0;
stopFlag = 1;
openPortFlag = 0;
stopAll = 0;

dispPredictionDialog();
drawnow

while ~stopAll 
    if startAllFlag
%         try
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
                timerObj = timer;
                set(timerObj,'StartFcn', {@startTimerFcn, tB, parameters});
                set(timerObj,'TimerFcn', {@startTimerFcn, tB, parameters});
                set(timerObj,'StartDelay', 1);
                set(timerObj,'StopFcn', @stopTimerFcn);
                set(timerObj,'ExecutionMode','fixedRate');
                set(timerObj,'Period', toggleInterval);
                set(timerObj,'Tag','box');

                
            elseif ~stopFlag && openPortFlag
                % Send stimulation
                startingTime = tic;
                stopTime = toc(startingTime);
                start(timerObj);                
                while stopTime <= stimulationDuration
                    stopTime = toc(startingTime);
                end
                
                
                tNumber.String = num2str([0,0,0,0]);
                tStatus.String = 'Program stopped...';
                buttonStartStop.String = 'Start';
                buttonStartStop.ForegroundColor = [0,190/256,0];
                stopFlag = 1;
                openPortFlag = 0;
                
                drawnow
            else
                openPortFlag = 0;
                warning('off','all')
                boxesT = timerfind('Tag','box');
                if ~isempty(boxesT)
                    try
                        close(boxesT(:).UserData); % close the box window
                    catch
                    end
                    delete(boxesT)
                end
                
            end
            
%         catch
%             startAllFlag = 0;
%             tNumber.String = num2str([0,0,0,0]);
%             tStatus.String = 'Program stopped...';
%             buttonStartStop.String = 'Start';
%             buttonStartStop.ForegroundColor = [0,190/256,0];
%             stopFlag = 1;
%             openPortFlag = 0;
%             popMsg('Wrong selection, please start over...');
%             drawnow
%         end
    end
    drawnow
end
end

function startTimerFcn(~,~,tB,parameters)
global tNumber
global pair

switch pair % pair channels stimulation
    case 1 % stimulate channel 1 & 3
        stimulationCh = [1,0,1,0];
        pair = 2;
        
    case 2 % stimulate channel 2 & 4
        stimulationCh = [0,1,0,1];
        pair = 1;
        
    otherwise
end

replyPredictionDec = bi2de(stimulationCh,'left-msb');
fwrite(tB,[parameters.channelEnable,replyPredictionDec]); % to enable the channel
tNumber.String = num2str(stimulationCh);
drawnow
end

function stopTimerFcn(~,~)
end

