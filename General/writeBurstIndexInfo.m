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
    catch
        numCol = 0;
    end
    
    xlswrite([signal(i,1).path,'info.xlsx'],typeName, 1, [char(numCol+1+64),'1']);
    xlswrite([signal(i,1).path,'info.xlsx'],{['parameters.channel: ',num2str(parameters.channel)]},1,[char(numCol+1+64),'2']); % parameters.channel
    if ~isempty(signal(i,1).analysedDataTiming)
        xlswrite([signal(i,1).path,'info.xlsx'],{checkMatNAddStr(signal(i,1).analysedDataTiming(1,:),' - ',1)},1,[char(numCol+2+64),'2']); % parameters.channel
    end
    xlswrite([signal(i,1).path,'info.xlsx'],{signal(i,1).file(5:8)},1,[char(numCol+1+64),'3']); % parameters.channel
    xlswrite([signal(i,1).path,'info.xlsx'],cell2nanMat(signalClassification(i,1).burstDetection.selectedBurstsIndex),1,[char(numCol+1+64),'4']);
end

end