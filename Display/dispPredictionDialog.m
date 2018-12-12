function dispPredictionDialog()
%DISPPREDICTIONDIALOG Summary of this function goes here
%   Detailed explanation goes here
close hidden

global startAllFlag
global stopFlag
global openPortFlag
global classifierParameters
global tNumber
global buttonStartStop
global tStatus
global stopAll

warning('off','all');

a=[0,0,0,0];

textSize = 25;
textReselectSize = 10;
textSizePredictionClass = 50;
screenSize = get(0,'Screensize');
windowPosition = [1, screenSize(1,4)*.7, screenSize(1,3)*.25, screenSize(1,4)*.25];

p = figure('Name','SINAPSE CAT V1','NumberTitle','off','CloseRequestFcn',@closeProgram);
set(gcf, 'Position', windowPosition, 'MenuBar', 'none', 'ToolBar', 'none');


tStatus = uicontrol(gcf,'Style','text','String','Program stopped...','HorizontalAlignment','left','FontSize',textSize,'Unit','normalized','Position',[0.15,0.66,0.6,0.25]);

tNumber = uicontrol(gcf,'Style','text','String',num2str(a),'FontSize',textSizePredictionClass,'Unit','normalized','Position',[0.1,0.43,0.8,0.3]);

buttonStartStop = uicontrol(gcf,'Style','push','String','Start','FontWeight','bold','ForegroundColor',[0,190/256,0],'FontSize',textSize,'Unit','normalized','Position',[.15,0.1,0.7,0.25],'CallBack',@changeState);

buttonReselect = uicontrol(gcf,'Style','push','String','Reselect','FontWeight','bold','ForegroundColor','k','FontSize',textReselectSize,'Unit','normalized','Position',[.78,0.855,0.2,0.1],'CallBack',@reselectFile);
buttonTrain = uicontrol(gcf,'Style','push','String','Train','FontWeight','bold','ForegroundColor','k','FontSize',textReselectSize,'Unit','normalized','Position',[.78,0.755,0.2,0.1],'CallBack',@trainClassifier);


    function changeState(~,~)
        switch stopFlag
            case 0
                    disp('Program stopped...')
                    resetAll();
            case 1
                if startAllFlag
                    disp('Program started...')
                    tNumber.String = num2str([0,0,0,0]);
                    tStatus.String = 'Program started...';
                    buttonStartStop.String = 'Stop';
                    buttonStartStop.ForegroundColor = 'r';
                    openPortFlag = 0;
                    stopFlag = 0;
                else
                    popMsg('Select a trained .mat file first...');
                end
            otherwise
                disp('How did you get in here !?')
        end
        drawnow
    end

    function reselectFile(~,~)
        disp(' ')
        disp('Reselect training files...')
        try
            [files,path] = selectFiles('Select trained parameters .mat file...');
            classifierParameters = load(fullfile(path,files{1,1}));
            classifierParameters = classifierParameters.varargin{1,1};
            
            resetAll();
            
            startAllFlag = 1;
            
            popMsg('Trained file selected...');
        catch
            popMsg('Reselct failed...');
        end
        drawnow
    end

    function trainClassifier(~,~)
        disp(' ')
        try
            onlineClassifierTraining();
            resetAll();
            popMsg('Training done...');
        catch
            resetAll();
            popMsg('Training failed...');
        end
        drawnow
    end

    function resetAll()
        tNumber.String = num2str([0,0,0,0]);
        tStatus.String = 'Program stopped...';
        buttonStartStop.String = 'Start';
        buttonStartStop.ForegroundColor = [0,190/256,0];
        stopFlag = 1;
        openPortFlag = 0;
    end

    function closeProgram(~,~)
%         pause
        close all
        stopAll = 1;
    end
end


