function p = plots2Subplots(plots,rowSubplot,colSubplot)
%plots2Subplots Plot the plots into subplot
%   p = plots2Subplots(plots,dimSubplot,answerSave,answerShow,path)

textSize = 1;

figure
hold on;

plots = reshape(plots,rowSubplot,colSubplot);

for i = 1:rowSubplot
    for j = 1:colSubplot
        sp = subplot(rowSubplot,colSubplot,(i-1)*colSubplot+j);        
        copyAxes(plots(i,j), sp);
    end
end

set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',textSize,...
    'PaperPositionMode', 'auto');

end

