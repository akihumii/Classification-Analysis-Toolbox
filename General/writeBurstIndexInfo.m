function [] = writeBurstIndexInfo(signal,signalClassification,parameters)
%WRITEBURSTINDEXINFO Write the matrix into the excel file.
%
%   [] = writeBurstIndexInfo(signal,parameters)

numData = length(signal);

for i = 1:numData
    switch parameters.burstTrimming
        case 0
            break
        case 1
            typeName = {'delete bursts'};
        case 2
            typeName = {'pick bursts'};
    end
    
    try
        [num,~,~] = xlsread([signal(i,1).path,'info.xlsx']);
        numCol = size(num,2);
        letterFirst = floor(numCol/26);
        letterLast = mod(numCol,26);
    catch
        letterFirst = 0;
        letterLast = 0;
    end
    
    if letterFirst == 0
        col = char(letterLast+1+64);
    else
        col = [char(letterFirst+64),char(letterLast+1+64)];
    end
    
    xlswrite([signal(i,1).path,'info.xlsx'],typeName, 1, [col,'1']);
    xlswrite([signal(i,1).path,'info.xlsx'],{['parameters.channel: ',num2str(parameters.channel)]},1,[col,'2']); % parameters.channel
    if ~isempty(signal(i,1).analysedDataTiming)
        xlswrite([signal(i,1).path,'info.xlsx'],{checkMatNAddStr(signal(i,1).analysedDataTiming(1,:),' - ',1)},1,[col,'2']); % parameters.channel
    end
    xlswrite([signal(i,1).path,'info.xlsx'],{signal(i,1).file(5:8)},1,[col,'3']); % parameters.channel
    xlswrite([signal(i,1).path,'info.xlsx'],...
        [cell2nanMat(signalClassification(i,1).burstDetection.selectedBurstsIndex);nan(1,length(signalClassification(i,1).burstDetection.selectedBurstsIndex))],1,[col,'4']);
end

end