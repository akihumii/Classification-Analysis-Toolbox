function output = selectPartialData(time, data, fileName, path, window, samplingFreq)
%selectPartialSignals Select a portion of data. 
%   output = selectPartialSignals(time, data, fileName, path, window, samplingFreq)
%
% output.partialData = partial data value
% output.startLocs = starting locations of the partial data
% output.endLocs = end location of the partial data

%% Main
plotFig(time/samplingFreq,data,fileName,'Select Partial Signal (press any key to continue...)','Time(s)','Amplitude(V)',0,1,path,'subplot');

hold all

xLimit = get(gca,'xLim');
yLimit = get(gca,'yLim');

if nargin < 4 || length(window)==1
    window = xLimit;
end

h = imrect(gca,[window(1),yLimit(1),diff(window),diff(yLimit)]);
fcn = makeConstrainToRectFcn('imrect',xLimit,yLimit);
setPositionConstraintFcn(h,fcn);

pause;

locs = h.getPosition;
startLocs = floor((locs(1,1) - time(1,1)/samplingFreq) * samplingFreq + 1);
if startLocs <= 0
    startLocs = 1;
end
endLocs = startLocs + floor((locs(3) * samplingFreq));

close

partialData = data(startLocs:endLocs,:);

output.partialData = partialData;
output.startLocs = startLocs;
output.endLocs = endLocs;
end

