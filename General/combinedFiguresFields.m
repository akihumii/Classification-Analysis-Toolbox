% function [] = combinedFiguresFields()
%combinedFiguresFields Combined each field from all the selected figures
%and plot them out in separate figures.
% 
%   [] = combinedFiguresFields()

clear

%% Select files and initialize
showFigure = 1;
saveFigure = 1;

[files, path, iter] = selectFiles();
fileName = files{1,1}(1:end-11);

figCheck = open(files{1,1});
numChannel = floor(length(figCheck.Children(2).Children) / 2);
delete(figCheck); clear figCheck

dataX = zeros(0,0,1);
dataY = zeros(0,0,1);
dataEX = zeros(0,0,1);
dataEY = zeros(0,0,1);
dataEL = zeros(0,0,1);

%% open separated files and get the values
for i = 1:iter
    fig(i,1) = open(files{1,i}); % open figures
    dataEX = cat(1,dataEX,cat(3,fig(i,1).Children(2).Children(numChannel:-1:1,1).XData)); % errorbar
    dataEY = cat(1,dataEY,cat(3,fig(i,1).Children(2).Children(numChannel:-1:1,1).YData)); % errorbar
    dataEL = cat(1,dataEL,cat(3,fig(i,1).Children(2).Children(numChannel:-1:1,1).LData)); % errorbar
    dataX = cat(1,dataX,cat(3,fig(i,1).Children(2).Children(end:-1:end-(numChannel-1),1).XData)); % order of channels is descending
    dataY = cat(1,dataY,cat(3,fig(i,1).Children(2).Children(end:-1:end-(numChannel-1),1).YData)); % [features, iter, channel]
end

numFeatures = size(dataX,2); 
[numRowSubplot,numColSubplot] = getFactors(numFeatures);

close all

%% combine the values into arranged figures
for i = 1:numChannel % to make it ascending again
    for j = 1:numFeatures
        [pS(j,i),fS(j,i)] = plotFig(1:iter,dataY(:,j,i),fileName,['Comparison of Feature ',num2str(j),' (ch ',num2str(i),')'],'Week','',0,1,path,'subplot',0,'barPlot');
        hold on
        errorbar(pS(j,i),getErrorBarXAxisValues(iter,1),dataEY(:,j,i),dataEL(:,j,i),'r*'); % plot errorbar
        titleName{j,1} = ['Accuracy across weeks of Feature ',num2str(j),' (ch ',num2str(i),')'];
    end
    
    [pA{i,1},fA(i,1)] = plots2subplots(pS(:,i),numRowSubplot,numColSubplot,titleName);
    
    legend('Accuracy','Errorbar')

    % save figures
    if saveFigure % save combined figures
        savePlot(path,'Accuracy across weeks',fileName,['Accuracy across weeks of Feature ',num2str(j),' (ch ',num2str(i),')'])
    end
end

delete(fS)
if ~showFigure
    delete(fA)
end

%% Finish
finishMsg(); % pop the finish message

% end

