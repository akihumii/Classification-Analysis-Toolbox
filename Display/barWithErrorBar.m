function varargout = barWithErrorBar(dataBar,dataStde,dataStar,varargin)
%BARWITHERRORBAR Plot bar plot with error bar and stars as median or mean
% output:   [p,h], both are optional
%   varargout = barWithErrorBar(dataBar,dataStde,dataStar,path,titleName,saveBarPlot,legendNames)

titleName = '';
legendNames = '';

if nargin > 3
    titleName = varargin{1,1};
end
if nargin > 4
    legendNames = varargin{1,2};
end

[numBar, numClass] = size(dataBar);

figure
p = bar(dataBar);
h = gca;
hold on
grid on
set(gcf, 'Position', get(0,'Screensize')-[0 0 0 80],'PaperPositionMode', 'auto');
if size(dataStde,3)==1
    errorbar(getErrorBarXAxisValues(numBar,numClass),dataBar,dataStde,'r*');
else
    errorbar(getErrorBarXAxisValues(numBar,numClass),dataBar,dataStde(:,:,1),dataStde(:,:,2),'r*');
end
if dataStar ~= 0
    plot(getErrorBarXAxisValues(numBar,numClass),dataStar,'g^')
end
title(titleName)

legend(legendNames);

if nargout > 1
    varargout{2} = h;
elseif nargout > 0
    varargout{1} = p;
end

end

