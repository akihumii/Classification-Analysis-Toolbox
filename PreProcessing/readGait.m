function [gaitLocs,gaitStats,path] = readGait()
%readGait Read the gait and output the location in sample points
%   [gaitLocs,path] = readGait()

close 
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

% Plot
dataAverage = gaitStats{1,:};
dataStde = gaitStats{4,:};
dataMed = gaitStats{3,:};
p = bar(dataAverage);
h = gca;
hold on
set(gcf, 'Position', get(0,'Screensize')-[0 0 0 80],'PaperPositionMode', 'auto');
xlabel('speed (cm/s)')
ylabel('Swing Length (ms)')
h.XTickLabel = gaitStats.Properties.VariableNames;
errorbar(1:iters,dataAverage,dataStde,'r*');
plot(1:iters,dataMed,'g^')
titleName = ['Overall Swing Length of ',path(end-8:end-1)];
title(titleName)
yLimit = ylim;
text(0,diff(yLimit)*0.1,'No. of steps:')
text(1:iters,repmat(diff(yLimit)*0.1,1,iters),cellstr(num2str(gaitStats{5,:}')))
saveas(gcf,[path,titleName,'.fig']);
saveas(gcf,[path,titleName,'.jpg']);

% save the info
writetable(gaitStats,[path,'GaitsInfo',time2string,'.xlsx'],'FileType','spreadsheet','WriteRowNames',true);

popMsg('Done :D');
end

