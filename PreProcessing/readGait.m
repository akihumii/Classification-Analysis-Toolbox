function [gaitLocs,gaitStats,path] = readGait()
%readGait Read the gait and output the location in sample points
%   [gaitLocs,path] = readGait()

[files,path,iters] = selectFiles('select gait data excel file');

popMsg('Processing gait data...');

[~, ~, raw] = xlsread([path,files{1,1}],'List');
[gaitLocs{1,1},gaitStats] = getGaitInfo(files{1,1},raw,'Rear Right');

for i = 2:iters
    [~, ~, raw] = xlsread([path,files{1,i}],'List');
    
    [gaitLocs{i,1},gaitStatsTemp] = getGaitInfo(files{1,i},raw,'Rear Right');
    
    gaitStats = join(gaitStats,gaitStatsTemp,'Keys','RowNames');
    
    clear raw
end

% save the info
writetable(gaitStats,[path,'GaitsInfo',time2string,'.xlsx'],'FileType','spreadsheet','WriteRowNames',true);

end

