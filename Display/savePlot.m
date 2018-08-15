function [] = savePlot(path,titleName,fileName,saveName,varargin)
%savePlot Save the current plots
% Plots will be save in path:
% [path, 'Figures\', titleName, '\', saveName, '.fig'];
% 
% input: fileName is for displaying only.
% 
%   [] = savePlot(path,titleName,fileName,saveName)

saveLocation = [path,'Figures',filesep,titleName];

if ~exist(saveLocation,'file')
    mkdir(saveLocation);
end

if length(varargin) == 0
    fig = gcf;
else
    fig = varargin{1,1};
end

saveas(fig,[saveLocation,filesep,saveName,'_',time2string,'.fig']);
saveas(fig,[saveLocation,filesep,saveName,'_',time2string,'.jpg']);

disp([saveLocation,filesep,saveName,'_',time2string,' is saved...'])
disp(' ')

end

