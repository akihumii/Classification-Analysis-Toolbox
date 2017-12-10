function f = plots2subplots(plots,rowSubplot,colSubplot,titleName)
%plots2subplots Plot the plots into subplot
% 
% input: titleName is optional
% 
%   p = plots2subplots(plots,rowSubplot,colSubplot,titleName)

if nargin < 4
    titleName = repmat({''},rowSubplot*colSubplot,1);
end
    
textSize = 1;

f = figure;
hold on;

newPlots = reshape(plots,rowSubplot,colSubplot);
titleName = reshape(titleName,rowSubplot,colSubplot);

for i = 1:rowSubplot
    for j = 1:colSubplot
        sp = subplot(rowSubplot,colSubplot,(i-1)*colSubplot+j);        
        copyAxes(newPlots(i,j), sp, titleName{i,j});
    end
end

set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',textSize,...
    'PaperPositionMode', 'auto');

end

