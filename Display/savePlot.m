function [] = savePlot(path,titleName,fileName,saveName)
%savePlot Save the current plots
% Plots will be save in path:
% [path, 'Figures\', titleName, '\', saveName, '.fig'];
% 
% input: fileName is for displaying only.
% 
%   [] = savePlot(path,titleName,fileName,saveName)

saveLocation = [path,'Figures\',titleName];

if ~exist(saveLocation,'file')
    mkdir(saveLocation);
end

saveas(gcf,[saveLocation,'\',saveName,'.fig']);
saveas(gcf,[saveLocation,'\',saveName,'.jpg']);

disp([titleName,' ',fileName, ' is saved...'])
disp(' ')

end

