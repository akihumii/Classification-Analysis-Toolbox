function tNumber = dispPredictionDialog()
%DISPPREDICTIONDIALOG Summary of this function goes here
%   Detailed explanation goes here
close all

global stopFlag

warning('off','all');

a=[0,0,0,0];

textSize = 25;
textSizePredictionClass = 50;
screenSize = get(0,'Screensize');
windowPosition = [1, screenSize(1,4)*.7, screenSize(1,3)*.25, screenSize(1,4)*.25];

p = figure('CloseRequestFcn',@closeProgram);
set(gcf, 'Position', windowPosition, 'MenuBar', 'none', 'ToolBar', 'none');


tStatus = uicontrol(gcf,'Style','text','String','Program started...','HorizontalAlignment','left','FontSize',textSize,'Unit','normalized','Position',[0.15,0.66,0.6,0.25]);

tNumber = uicontrol(gcf,'Style','text','String',num2str(a),'FontSize',textSizePredictionClass,'Unit','normalized','Position',[0.1,0.43,0.8,0.3]);

button = uicontrol(gcf,'Style','push','String','Stop','FontWeight','bold','ForegroundColor','r','FontSize',textSize,'Unit','normalized','Position',[.15,0.1,.7, .25],'CallBack',@changeState);

    function changeState(~,~)
        switch stopFlag
            case 0
                disp('Program stopped...')
                tStatus.String = 'Program stopped...';
                button.String = 'Start';
                button.ForegroundColor = [0,190/256,0];
                stopFlag = 1;
            case 1
                disp('Program started...')
                tStatus.String = 'Program started...';
                button.String = 'Stop';
                button.ForegroundColor = 'r';
                stopFlag = 0;
            otherwise
                disp('How did you get in here !?')
        end
    end

    function closeProgram(~,~)
        close all
%         exit
    end
end


