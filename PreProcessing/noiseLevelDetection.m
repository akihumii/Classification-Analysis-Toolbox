function dataSorted = noiseLevelDetection(data)
%noiseLevelDetection To detect noise level of the signal
%   Detailed explanation goes here

[rowData, colData] = size(data);

dataSorted = sort(data,1);

for i = 1:colData
%     p{i,1} = plotFig(dataSorted(:,i));
end

end

