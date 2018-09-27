function varargout = barWithErrorBar(dataBar,dataStde,dataStar,titleName,legendNames)
%BARWITHERRORBAR Plot bar plot with error bar and stars as median or mean
% output:   [p,h], both are optional
%   varargout = barWithErrorBar(dataBar,dataStde,dataStar,path,titleName,saveBarPlot,legendNames)
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
plot(getErrorBarXAxisValues(numBar,numClass),dataStar,'g^')
title(titleName)

legend(legendNames);

if nargout > 1
    varargout{2} = h;
elseif nargout > 0
    varargout{1} = p;
end

end

