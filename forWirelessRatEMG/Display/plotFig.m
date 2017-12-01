function p = plotFig(x, y, fileName, titleName, xScale, yScale , iter, answerSave, path)
%plotFig Summary of this function goes here
%   Detailed explanation goes here

figure
hold on;
set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',20,...
    'PaperPositionMode', 'auto');

for i = 1:iter
    p(i,1) = subplot(iter,1,i);
    plot(x,y(:,i));
    title([titleName, ' ', fileName{i}]);
    xlabel(xScale);
    ylabel(yScale);
    axis tight;
end

linkaxes(p(:,1),'x');

%% Save
if isequal(answerSave,'y')
    saveLocation = [path,'\',titleName];
    mkdir(saveLocation);
    saveas(gcf,[saveLocation,'\',fileName{1}(1:end-3),' ',titleName,'.fig']);
    saveas(gcf,[saveLocation,'\',fileName{1}(1:end-3),' ',titleName,'.jpg']);
end

end

