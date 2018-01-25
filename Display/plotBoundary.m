function [] = plotBoundary(hCurrent, constant, linear)
%plotBoundary Plot boundary of the classifier
%   h = plotBoundary(h, constant, linear)

xLimit = xlim(hCurrent);
yLimit = ylim(hCurrent);
numLine = size(constant,1);

for i = 1:numLine
%     f = @(x1,x2) constant(i,1) + linear(i,1)*x1 + linear(i,2)*x2; % original equation to get the function
    f = @(x1) (- constant(i,1) - linear(i,1)*x1) / linear(i,2); % let the function equal to zero, plot x2 against x1
    fplot(hCurrent,f,xLimit); % same as ezplot(h,f,[xLimit,yLimit])
end

hCurrent.YLim = yLimit;

end

