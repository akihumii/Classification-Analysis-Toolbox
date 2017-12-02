function output = selectPartialData(data, fileName, path)
%selectPartialSignals Select baseline signal portion and decoding burst
%signal portion
%   output = selectPartialSignals(data, fileName, path)
% 
% output.partialData = partial data value
% output.startLocs = starting locations of the partial data
% output.endLocs = end location of the partial data

plotFig(1:size(data,1),data,fileName,'Select Partial Signal (press any key to continue...)','Time(unit)','Amplitude(V)',0,1,path,'subplot');

hold all

xLimit = get(gca,'xLim');
yLimit = get(gca,'yLim');

h1Temp = plot(gca,[1,1],yLimit,'r-'); % starting line legend
h1 = imline(gca,[1 1],yLimit); % starting line
setColor(h1,'r');
fcn1 = makeConstrainToRectFcn('imline',xLimit,yLimit);
setPositionConstraintFcn(h1,fcn1);

h2Temp = plot(gca,[xLimit(2),xLimit(2)],yLimit,'g-'); % end line legend
h2 = imline(gca,[xLimit(2),xLimit(2)],yLimit); % end line
setColor(h2,'g');
fcn2 = makeConstrainToRectFcn('imline',xLimit,yLimit);
setPositionConstraintFcn(h2,fcn2);

legend([h1Temp,h2Temp],'starting point','end point')
pause(0.1)
delete([h1Temp,h2Temp])

pause; % press any key to continue

startLocs = h1.getPosition();
endLocs = h2.getPosition();
startLocs = floor(startLocs(1,1));
endLocs = floor(endLocs(1,1));

close

partialData = data(startLocs:endLocs,:);

output.partialData = partialData;
output.startLocs = startLocs;
output.endLocs = endLocs;
end

