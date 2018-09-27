function [dataAve,dataStde,dataMed] = collapseGaits(gaitStats,collapseGroup)
%COLLAPSEGAITS Summary of this function goes here
%   Detailed explanation goes here

numGroup = size(collapseGroup,1);

dataTemp = 0;

for i = 1:numGroup
    for j = collapseGroup(i,1) : collapseGroup(i,2)
        dataTemp = dataTemp + gaitStats{1,j} * gaitStats{5,j};
    end
    dataTemp = 0;
end


end

