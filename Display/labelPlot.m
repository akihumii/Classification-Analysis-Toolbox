function [] = labelPlot(h,x,marker)
%labelPlot Label the plot on the current chart
% 
% input:    h:  axes that is going to be plot on
%           x:  x values to be labeled
%   [] = labelPlot(h,x,mark)

numMarkers = length(x);

if numMarkers ~= 0
    yLimit = ylim(h);
    
    distance = abs(diff(yLimit))/20; % 1/20 of the y limit range
    
    xValues = h.Children.XData;
    yValues = h.Children.YData;
    
    markerValues = zeros(0,1);
    
    for i = 1:numMarkers
        xLocs(i,1) = find(xValues==x(i));
        signTemp = sign(yValues(xLocs(i)));
        if signTemp == 1
            markerValues(i,1) = yValues(xLocs(i)) + signTemp*distance;
        else
            markerValues(i,1) = distance;
        end
    end
    
    hM = plot(h,x,markerValues,marker);
    
    legend(hM,'significantly different')    
end

end

