function [] = writeBurstIndexInfo(path,channel,type,speed,timing,data)
%WRITEBURSTINDEXINFO Write the matrix into the excel file.
% 
%   [] = writeBurstIndexInfo(path,title,subtitle,data)

switch type
    case 1
        typeName = {'delete bursts'};
    case 2
        typeName = {'pick bursts'};
end

try
    [num,~,~] = xlsread([path,'info.xlsx']);
    numCol = size(num,2);
catch
    numCol = 0;
end

xlswrite([path,'info.xlsx'],typeName, 1, [char(numCol+1+64),'1']);
xlswrite([path,'info.xlsx'],{['channel: ',num2str(channel)]},1,[char(numCol+1+64),'2']); % channel
if ~isempty(timing)
    xlswrite([path,'info.xlsx'],{checkMatNAddStr(timing(1,:),' - ',1)},1,[char(numCol+2+64),'2']); % channel
end
xlswrite([path,'info.xlsx'],{speed},1,[char(numCol+1+64),'3']); % channel
xlswrite([path,'info.xlsx'],cell2nanMat(data),1,[char(numCol+1+64),'4']);

end