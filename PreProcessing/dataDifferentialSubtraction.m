function dataDifferential = dataDifferentialSubtraction(data, channelRef)
%channelDifferential Output the differential signal with respect to
%reference channel
%   data = dataDifferential(data, channelRef)
numChannel = size(data,2);
dataSubject = 1:numChannel;
dataSubject(channelRef) = []; % differential channels to obtain with respect to reference channel
dataDifferential(:,1) = data(:,1);
for i = 2:numChannel-1
    dataDifferential(:,i) = data(:,dataSubject(i)) - data(:,channelRef);
end

end

