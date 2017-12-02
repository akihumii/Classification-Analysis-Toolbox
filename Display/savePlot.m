function [] = savePlot(path,titleName,fileName,saveName)
%savePlot Save the current plots
%   [] = savePlot(path,titleName,fileName)

saveLocation = [path,'Figures\',titleName];

if ~exist(saveLocation,'file')
    mkdir(saveLocation);
end

saveas(gcf,[saveLocation,'\',saveName,'.fig']);
saveas(gcf,[saveLocation,'\',saveName,'.jpg']);

disp([titleName,' ',fileName, ' is saved...'])

end

