function output = selectPartialData(time, data, fileName, path, window, samplingFreq, varargin)
%selectPartialSignals Select a portion of data. 
%   varargin: {1,1}: 1 to plot figure, vice versa
%             {1,2}: axes to be plot
%   output = selectPartialSignals(time, data, fileName, path, window, samplingFreq)
%
% output.partialData = partial data value
% output.startLocs = starting locations of the partial data
% output.endLocs = end location of the partial data

%% Main
if nargin < 8
    plotFig(time/samplingFreq,data,fileName,'Select Partial Signal (press any key to continue...)','Time(s)','Amplitude(V)',0,1,path,'subplot');
elseif varargin{1,1} == 1
    plotFig(time/samplingFreq,data,fileName,'Select Partial Signal (press any key to continue...)','Time(s)','Amplitude(V)',0,1,path,'subplot');
    hGca = gca;
else
    hGca = varargin{1,2};
end

hold on

xLimit = get(hGca,'xLim');
yLimit = get(hGca,'yLim');

if nargin < 4 || length(window)==1
    window = xLimit;
end

h = imrect(hGca,[window(1),yLimit(1),diff(window),diff(yLimit)]);
fcn = makeConstrainToRectFcn('imrect',xLimit,yLimit);
setPositionConstraintFcn(hGca,fcn);

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

