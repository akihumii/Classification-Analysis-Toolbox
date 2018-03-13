function newData = decimateData(data,downSamplingFreq,originalSamplingFreq)
%decimateData Down sampling the data by columns
%   newData = decimateData(data,downSamplingFreq,originalSamplingFreq)

[numRow, numCol] = size(data);

decimateFactor = originalSamplingFreq / downSamplingFreq ;

if numRow == 1
    data = data';
    [numRow, numCol] = size(data);
end

for i = 1:numCol
    newData(:,i) = decimate(data(:,i),decimateFactor);
end

end

