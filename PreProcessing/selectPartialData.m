function output = selectPartialData(data, fileName, path, windowSize)
%selectPartialSignals Select baseline signal portion and decoding burst
%signal portion. Type can be 'line' or 'box'.
%   output = selectPartialSignals(data, fileName, path)
%
% output.partialData = partial data value
% output.startLocs = starting locations of the partial data
% output.endLocs = end location of the partial data

%% Main
plotFig(1:size(data,1),data,fileName,'Select Partial Signal (press any key to continue...)','Time(unit)','Amplitude(V)',0,1,path,'subplot');

hold all

xLimit = get(gca,'xLim');
yLimit = get(gca,'yLim');

if windowSize == 0
    windowSize = diff(xLimit);
end

h = imrect(gca,[xLimit(1),yLimit(1),windowSize,diff(yLimit)/2]);
fcn = makeConstrainToRectFcn('imrect',xLimit,yLimit);
setPositionConstraintFcn(h,fcn);

pause;

locs = h.getPosition;
startLocs = floor(locs(1,1));
endLocs = startLocs + floor(locs(3));

close

partialData = data(startLocs:endLocs,:);

output.partialData = partialData;
output.startLocs = startLocs;
output.endLocs = endLocs;
end

