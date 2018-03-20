% function [] = combinedFiguresFields()
%combinedFiguresFields Combined each field from all the selected figures
%and plot them out in separate figures.
% 
%   [] = combinedFiguresFields()

clear
close all

%% Select files and initialize
showFigure = 1;
saveFigure = 1;

[files, path, iter] = selectFiles();
fileName = files{1,1}(1:end-11);

figCheck = open([path,files{1,1}]);
numChannel = floor(length(figCheck.Children(2).Children) / 2);
delete(figCheck); clear figCheck

dataX = zeros(0,0,1);
dataY = zeros(0,0,1);
dataEX = zeros(0,0,1);
dataEY = zeros(0,0,1);
dataEL = zeros(0,0,1);

%% open separated files and get the values
for i = 1:iter
    fig(i,1) = open([path,files{1,i}]); % open figures
    dataEY = cat(1,dataEY,cat(3,fig(i,1).Children(2).Children(numChannel:-1:1,1).YData)); % errorbar
    dataEL = cat(1,dataEL,cat(3,fig(i,1).Children(2).Children(numChannel:-1:1,1).LData)); % errorbar
    dataX = cat(1,dataX,cat(3,fig(i,1).Children(2).Children(end:-1:end-(numChannel-1),1).XData)); % order of channels is descending
    dataY = cat(1,dataY,cat(3,fig(i,1).Children(2).Children(end:-1:end-(numChannel-1),1).YData)); % [features, iter, channel]
end

numFeatures = size(dataX,2); 
[numRowSubplot,numColSubplot] = getFactors(numFeatures);
% numRowSubplot = 2;
% numColSubplot = 6;

close all

%% combine and plot the values in arranged figures
for i = 1:numChannel % to make it ascending again
    % Plot the barplots
    for j = 1:numFeatures
        [pS(j,i),fS(j,i)] = plotFig(1:iter,dataY(:,j,i),fileName,['Comparison of Features (ch ',num2str(i),')'],'Week','',0,1,path,'subplot',0,'barPlot');
        hold on; ylim([0,1]); grid on
        errorbar(pS(j,i),getErrorBarXAxisValues(iter,1),dataEY(:,j,i),dataEL(:,j,i),'r*'); % plot errorbar
        titleName{j,1} = ['Accuracy across weeks of Features (ch ',num2str(i),')'];
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

%% plot the variance of features across weeks
dataYInfo = getBasicParameter(dataY(:,:,:));
[pF,fF] = plotFig(1:numFeatures,dataYInfo.mean,fileName,'Mean accuracy of features across weeks','Feature','',0,1,path,'subplot',0,'barStackedPlot');
hold on; ylim([0,1]); grid on
errorbar(getErrorBarXAxisValues(numFeatures,2),dataYInfo.mean,dataYInfo.stde,'r*'); % plot errorbar
legend('Channel 1','Channel 2')
if saveFigure
    savePlot(path,'Mean accuracy of features across weeks',fileName,'Mean accuracy of features across weeks');
end
if ~showFigure
    delete(fF)
end

%% normal distribution testing
for i = 1:numChannel
    for j = 1:numFeatures
        lillieTestResult(j,i) = lillietest(dataY(:,j,i)) % 0 means null hypothesis 'the data are normaly distributed' can't be rejected, otherwise then 1
    end
end

%% Finish
finishMsg(); % pop the finish message

% end

