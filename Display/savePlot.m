function [] = savePlot(path,titleName,fileName)
%savePlot Save the current plots
%   [] = savePlot(path,titleName,fileName)
saveName = [titleName, ' ', fileName];

saveLocation = [path,'Figures\',titleName];

if ~exist(saveLocation,'file')
    mkdir(saveLocation);
end

saveas(gcf,[saveLocation,'\',saveName,'.fig']);
saveas(gcf,[saveLocation,'\',saveName,'.jpg']);

disp([titleName,' ',fileName, ' is saved...'])

end
