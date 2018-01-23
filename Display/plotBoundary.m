function h = plotBoundary(h, constant, linear)
%plotBoundary Plot boundary of the classifier
%   h = plotBoundary(h, constant, linear)

axes(h)
xLimit = xlim(h);
yLimit = ylim(h);
numLine = size(constant,1);

for i = 1:numLine
    f = @(x1,x2) constant(i,1) + linear(i,1)*x1 + linear(i,2)*x2;
    h(i,1) = ezplot(f,[xLimit,yLimit]);
end

end

