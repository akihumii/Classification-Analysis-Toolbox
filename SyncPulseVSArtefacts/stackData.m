function data = stackData(dataRaw)
%stackData Stack two channels of data
%   data = stackData(dataRaw)

numRow = length(dataRaw);
numChannel = 2;

data(:,1) = vertcat(dataRaw(4:5:numRow).Data);
data(:,2) = vertcat(dataRaw(6:5:numRaow).Data);

end

