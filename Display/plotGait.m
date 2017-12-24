function [] = plotGait(gaitLocs,saveFigure,showFigure,gaitFilePath)
%plotGait Plot the starting and end location of gaits in current axes
%   [] = plotGait(gaitLocs)

% Get all axes in current figure
[files,path] = selectFiles('select figure that is going to be used for plotting');

open([path,files{1}])
fileName = files{1}(1:end-4);

p = gcf;

numGraphics = length(p.Children);

allLegend = p.Children(1:2:numGraphics);
allAxes = p.Children(2:2:numGraphics);

numAxes = length(allAxes);

gaitLocs = gaitLocs';
startLocs = gaitLocs(1,:);
endLocs = gaitLocs(2,:);

%% plot starting stance line and end stance line on the sub plots
for i = 1:numAxes
    axes(allAxes(i,1));
    startingPoint = allAxes(i,1).Children(2);
    endPoint = allAxes(i,1).Children(1);
    hold on
    yLimit = allAxes(i,1).YLim;
    startStance = plot(allAxes(i,1),repmat(startLocs,2,1)+allAxes(i,1).Children(end).XData(1),yLimit,'r-');
    endStance = plot(allAxes(i,1),repmat(endLocs+allAxes(i,1).Children(end).XData(1),2,1),yLimit,'g-');
    legend([startingPoint,endPoint,startStance(1),endStance(1)],'starting point','end point','starting stance','end stance');
    hold off
    
    [reconstructedData{numAxes-(i-1),1},reconstructedTime{numAxes-(i-1),1}] =... % the data is in reversed sequence, so reconstructedData will sort in reverse sequence
        reconstructGait(gaitLocs,allAxes(i,1).Children(end).XData,allAxes(i,1).Children(end).YData);
end

if saveFigure
    savePlot(gaitFilePath,'Overall Signal with Gaits Indicated',fileName,['Gaits ',files{1}(1:end-4)]);
end

if ~showFigure
    close
end
%% plot overlapping windows according to the starting stance line
overallData = cell2nanMat(reconstructedData);
overallTime = cell2nanMat(reconstructedTime);
titleName = 'Overlapped Stance Windows';
p = plotFig(overallTime,overallData,fileName,titleName,'Time (s)','Amplitude (V)',...
    0,... % save
    1,... % show
    gaitFilePath,'overlap');

% plot subplots
plots2subplots(p,2,1);

if saveFigure
    savePlot(gaitFilePath,titleName,fileName,[titleName,' Subplots']);
end

if ~showFigure
    close all
end
    

end

