function newData = decimateData(data,factor)
%decimateData Down sampling the data by columns
%   newData = decimateData(data,factor)

[numRow, numCol] = size(data);

if numRow == 1
    data = data';
    [numRow, numCol] = size(data);
end

for i = 1:numCol
    newData(:,i) = decimate(data(:,i),factor);
end

end

