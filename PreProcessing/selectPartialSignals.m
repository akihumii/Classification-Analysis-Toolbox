function output = selectPartialSignals(data, fileName, path)
%selectPartialSignals Select baseline signal portion and decoding burst
%signal portion
%   [] = selectPartialSignals(data, fileName, path)

numFile = length(data); % number of trials

for i = 1:numFile
    plotFig(1:size(data{i,1},1),data{i,1},fileName{i,1},'Select Baseline Signal Portion','Time(unit)','Voltage(V)','n','y',path,'n');
    baselineSectionTiming{i,1} = selectPartial(); % part of signal that is set as baseline
    baselineParameter{i,1} = basicParameter(data{i,1}(baselineSectionTiming{i,1}.timeStart:baselineSectionTiming{i,1}.timeEnd,:));
    
    plotFig(1:size(data{i,1},1),data{i,1},fileName{i,1},'Select Decoding Signal Portion','Time(unit)','Voltage(V)','n','y',path,'n');
    burstSectionTiming{i} = selectPartial(); % part of signal that contains the bursts that are going to be analysed
    
    close
end

output.baselineSectionTiming = baselineSectionTiming;
output.baselineParameter = baselineParameter;
output.burstSectionTiming = burstSectionTiming;
end

