function [gaitLocs,gaitStats,path] = readGait()
%readGait Read the gait and output the location in sample points
%   [gaitLocs,path] = readGait()

[files,path,iters] = selectFiles('select gait data excel file');

popMsg('Processing gait data...');

[~, ~, raw] = xlsread([path,files{1,1}],'List');
[gaitLocs{1,1},gaitStatsAve,gaitStatsStd,gaitStatsMed] = getGaitInfo(files{1,1},raw,'Rear Right');

for i = 2:iters
    [~, ~, raw] = xlsread([path,files{1,i}],'List');
    
    [gaitLocs{i,1},gaitStatsAveTemp,gaitStatsStdTemp,gaitStatsMedTemp] = getGaitInfo(files{1,i},raw,'Rear Right');
    
    gaitStatsAve = join(gaitStatsAve,gaitStatsAveTemp,'Keys','RowNames');
    gaitStatsStd = join(gaitStatsStd,gaitStatsStdTemp,'Keys','RowNames');
    gaitStatsMed = join(gaitStatsMed,gaitStatsMedTemp,'Keys','RowNames');
    
    clear raw gaitStatsAveTemp gaitStatsStdTemp gaitStatsMedTemp
end

% save the info
fileName = [path,'GaitsInfo',time2string,'.xlsx'];
writetable(gaitStatsAve,fileName,'FileType','spreadsheet','WriteRowNames',true,'Sheet','Average');
writetable(gaitStatsStd,fileName,'FileType','spreadsheet','WriteRowNames',true,'Sheet','Std');
writetable(gaitStatsMed,fileName,'FileType','spreadsheet','WriteRowNames',true,'Sheet','Median');

end

