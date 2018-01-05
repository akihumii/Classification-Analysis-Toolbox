function dataDifferential = dataDifferentialSubtraction(data, channelPair)
%channelDifferential Output the differential signal accroding to
%channelPair
%   data = dataDifferential(data, channelPair)

[rowData,colData] = size(data);

dataDifferential = zeros(rowData,0); % initate dataDifferential

dataTemp = data(:,channelPair); % rearrange the sequence according to channelPair, then first column  will minus second column etc

for i = 1:2:colData
    dataDifferential = [dataDifferential,dataTemp(:,i+1) - dataTemp(:,i)];
end

end