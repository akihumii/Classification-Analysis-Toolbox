function dataDifferential = dataDifferentialSubtraction(data, channelRef)
%channelDifferential Output the differential signal with respect to
%reference channel
%   data = dataDifferential(data, channelRef)
numChannel = size(data,2);

for i = 1:numChannel
    dataDifferential(:,i) = data(:,i) - data(:,channelRef);
end

dataDifferential(:,channelRef) = data(:,channelRef); % for the sake of classification 

end