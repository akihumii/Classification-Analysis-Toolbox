function tNumber = dispPredictionDialog()
%DISPPREDICTIONDIALOG Summary of this function goes here
%   Detailed explanation goes here
close all

global stopFlag

a=[1,0,0,1];

textSize = 25;
textSizePrediction = 35;
buttonSize = [.3, .25];
screenSize = get(0,'Screensize');
windowPosition = [1, screenSize(1,4)*.66, screenSize(1,3)*.25, screenSize(1,4)*.3];

p = figure('CloseRequestFcn',@closeProgram);
set(gcf, 'Position', windowPosition, 'MenuBar', 'none', 'ToolBar', 'none');


tPC = uicontrol(gcf,'Style','text','String','Predicted Class:','FontSize',textSize,'Position',[1,250,300,50]);

tNumber = uicontrol(gcf,'Style','text','String',num2str(a),'FontSize',textSizePrediction,'Position',[80,155,300,50]);

wStart = uicontrol(gcf,'Style','push','String','Start','FontSize',textSize,'Unit','normalized','Position',[.1,.05,buttonSize],'CallBack',@startProgram);
wStop = uicontrol(gcf,'Style','push','String','Stop','FontSize',textSize,'Unit','normalized','Position',[.6,.05,buttonSize],'CallBack',@stopProgram);

    function startProgram(~,~)
        disp('Program started...')
        stopFlag = 0;
    end

    function stopProgram(~,~)
        disp('Program stopped...')
        stopFlag = 1;
    end

    function closeProgram(~,~)
        exit
    end
end


