function dataDifferential = dataDifferentialSubtraction(data, channelPair)
%channelDifferential Output the differential signal accroding to
%channelPair
%   data = dataDifferential(data, channelPair)

rowData = size(data,1);

dataDifferential = zeros(rowData,0); % initate dataDifferential

dataTemp = data(:,channelPair); % rearrange the sequence according to channelPair, then first column  will minus second column etc

colDataTemp = size(dataTemp,2);

for i = 1:2:colDataTemp
    dataDifferential = [dataDifferential,dataTemp(:,i+1) - dataTemp(:,i)];
end

end