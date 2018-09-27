function [gaitLocs,gaitStats,path] = readGait()
%readGait Read the gait and output the location in sample points
%   [gaitLocs,path] = readGait()

%% Parameters
parameters = struct(...
    'saveInfo',0,...
    'plotBarPlot',1,...
    'saveBarPlot',0,...
    'collapseGroup',[1,3;4,7;8,12;13,14]);

%% Choose file
close 
[files,path,iters] = selectFiles('select gait data excel file');

popMsg('Processing gait data...');

%% Process
[~, ~, raw] = xlsread([path,files{1,1}],'List');
[gaitLocs{1,1},gaitStats] = getGaitInfo(files{1,1},raw,'Rear Right');

for i = 2:iters
    [~, ~, raw] = xlsread([path,files{1,i}],'List');
    
    [gaitLocs{i,1},gaitStatsTemp] = getGaitInfo(files{1,i},raw,'Rear Right');
    
    gaitStats = join(gaitStats,gaitStatsTemp,'Keys','RowNames');
    
    clear raw
end

%% save the info
if parameters.saveInfo
    writetable(gaitStats,[path,'GaitsInfo',time2string,'.xlsx'],'FileType','spreadsheet','WriteRowNames',true);
end

%% collapse
if parameters.collapseGroup > 0
    [dataAverage,dataStde,dataMed] = collapseGaits(gaitStats,parameters.collapseGroup);
end

%% Plot
dataAverage = gaitStats{1,:};
dataStde = gaitStats{4,:};
dataMed = gaitStats{3,:};

[p,h] = barWithErrorBar(dataAverage,dataStde,dataMed,parameters.saveBarPlot,...
    ['Overall Swing Length of ',path(end-8:end-1)],'');
xlabel('speed (cm/s)')
ylabel('Swing Length (ms)')
h.XTickLabel = gaitStats.Properties.VariableNames;
yLimit = ylim;
text(0,diff(yLimit)*0.1,'No. of steps:')
text(1:iters,repmat(diff(yLimit)*0.1,1,iters),cellstr(num2str(gaitStats{5,:}')))

if saveBarPlot
    saveas(gcf,[path,['Overall Swing Length of ',path(end-8:end-1)],'.fig']);
    saveas(gcf,[path,['Overall Swing Length of ',path(end-8:end-1)],'.jpg']);
end

if parameters.plotBarPlot
    close
end

popMsg('Done :D');
end

