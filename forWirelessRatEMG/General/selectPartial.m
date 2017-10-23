function [output] = selectPartial()
%selectPartial Summary of this function goes here
%   Detailed explanation goes here
hold all

xLimit = get(gca,'xLim');
yLimit = get(gca,'yLim');

h1 = imline(gca,[1 1],yLimit);
setColor(h1,'r');
fcn1 = makeConstrainToRectFcn('imline',xLimit,yLimit);
setPositionConstraintFcn(h1,fcn1);

h2 = imline(gca,[xLimit(2),xLimit(2)],yLimit);
setColor(h2,'g');
fcn2 = makeConstrainToRectFcn('imline',xLimit,yLimit);
setPositionConstraintFcn(h2,fcn2);

pause;

timeStart = h1.getPosition();
timeEnd = h2.getPosition();
output.timeStart = timeStart(1,1);
output.timeEnd = timeEnd(1,1);
close
end

