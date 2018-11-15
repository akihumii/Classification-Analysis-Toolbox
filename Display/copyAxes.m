function newAx = copyAxes(f,oldF, newAx, titleName)
%copyAxes Copy the axes from oldAx to newAx
%   [] = copyAxes(oldAx, newAx, titleName)

oldAx = findobj(oldF,'Type','axes');
oldAx.Position = newAx.Position;

if ~isempty(titleName)
    title(oldAx,titleName);
end

drawnow

copyobj(oldF.Children,f);
delete(newAx);

% copyobj(oldAx.XLabel,newAx);
% newAx.XLim = oldAx.XLim;
% 
% copyobj(oldAx.YLabel,newAx);
% newAx.YLim = oldAx.YLim;
end

