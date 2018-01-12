function output = cell2nanMat(data)
%cell2nanMat Convert cell into matrix filled with NaN based on largest
%column and row number. Input data must be in the form of cell array filled
%with vector array
%   output = cell2nanMat(data)

numCell = length(data);

for i = 1:numCell
    [numElement(i,1),numSet(i,1)] = size(data{i});
    if numElement(i,1) == 1 && numSet(i,1) ~= 1
        numElement(i,1) = numSet(i,1);
        numSet(i,1) = 1;
    end
end

maxElementLength = max(numElement);
maxSetLength = max(numSet);

if any(numSet > 1)
    output = nan(maxElementLength, maxSetLength, numCell);
    for i = 1:numCell
        if numElement(i,1)~=0 && numSet(i,1)~=0
            output(1:numElement(i,1),1:numSet(i,1),i) = data{i,1};
        end
    end
else
    output = nan(maxElementLength, numCell); % create empty nan matrix for the case of different numSpikes in different channels
    for i = 1:numCell
        if numElement(i,1)~=0
            output(1:numElement(i,1),i) = data{i,1};
        end
    end
end
end
