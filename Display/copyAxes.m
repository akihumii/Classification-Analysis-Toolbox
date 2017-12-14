function newAx = copyAxes(oldAx, newAx, titleName)
%copyAxes Copy the axes from oldAx to newAx
%   [] = copyAxes(oldAx, newAx, titleName)
copyobj(allchild(oldAx),newAx);

if isempty(titleName)
    copyobj(oldAx.Title,newAx);
    set(newAx.Title,'FontSize',2);
else
    title(newAx,titleName);
end

copyobj(oldAx.XLabel,newAx);
newAx.XLim = oldAx.XLim;

copyobj(oldAx.YLabel,newAx);
newAx.YLim = oldAx.YLim;
end

