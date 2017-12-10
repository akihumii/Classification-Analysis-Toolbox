function [] = copyAxes(oldAx, newAx)
%copyAxes Copy the axes from oldAx to newAx
%   [] = copyAxes(oldAx, newAx)
copyobj(allchild(oldAx),newAx);

newAx.Title = oldAx.Title;
newAx.Title.FontSize = 8;

newAx.XLabel = oldAx.XLabel;
newAx.XLim = oldAx.XLim;

newAx.YLabel = oldAx.YLabel;
newAx.YLim = oldAx.YLim;
end

