function [] = plotGait(gaitLocs)
%plotGait Plot the starting and end location of gaits in current axes
%   [] = plotGait(gaitLocs)

% Get all axes in current figure
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
    startStance = plot(allAxes(i,1),repmat(startLocs,2,1),yLimit,'r-');
    endStance = plot(allAxes(i,1),repmat(endLocs,2,1),yLimit,'g-');
    legend([startingPoint,endPoint,startStance(1),endStance(1)],'starting point','end point','starting stance','end stance');
    hold off
    
    [reconstructedData{i,1},reconstructedTime{i,1}] = reconstructGait(gaitLocs,allAxes(i,1).Children(end).XData,allAxes(i,1).Children(end).YData);
end

%% plot overlapping windows according to the starting stance line
overallData = cell2nanMat(reconstructedData);
overallTime = cell2nanMat(reconstructedTime);
plotFig(overallTime,overallData,'','Overlapped Stance Windows','Time (s)','Amplitude (V)',0,1,'','overlap')

end

