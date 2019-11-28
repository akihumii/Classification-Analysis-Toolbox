function output = cell2nanMat(data)
%cell2nanMat Convert cell into matrix filled with NaN based on largest
%column and row number. Input data must be in the form of cell array filled
%with vector array.
% In 4D output, the first layer (:,:,:,1) will be the first cell, which is
% a 3D matrix.
%
%   output = cell2nanMat(data)

numCell = length(data);
stringDataFlag = isstring(data{1}(1));
if ~iscell(data)
    warning('Input data for cell2nanMat is not a cell...')
else
    if numCell == 1
        output = data{1,1};
    elseif numCell == 0
        output = 0;
    else
        for i = 1:numCell
            [numElement(i,1),numSet(i,1),numLayer(i,1)] = size(data{i});
            if numElement(i,1) == 1 && numSet(i,1) ~= 1
                numElement(i,1) = numSet(i,1);
                numSet(i,1) = 1;
            end
        end
        
        maxElementLength = max(numElement);
        maxSetLength = max(numSet);
        maxLayer = max(numLayer);
        
        if any(numLayer > 1)
            if stringDataFlag
                output = strings(maxElementLength, maxSetLength, maxLayer, numCell);
            else
                output = nan(maxElementLength, maxSetLength, maxLayer, numCell);
            end
            for i = 1:numCell
                if numElement(i,1)~=0 && numSet(i,1)~=0 && numLayer(i,1)~=0
                    output(1:numElement(i,1),1:numSet(i,1),1:numLayer(i,1),i) = data{i};
                end
            end
            
        elseif any(numSet > 1)
            if stringDataFlag
                output = strings(maxElementLength, maxSetLength, numCell);
            else
                output = nan(maxElementLength, maxSetLength, numCell);
            end
            for i = 1:numCell
                if numElement(i,1)~=0 && numSet(i,1)~=0
                    output(1:numElement(i,1),1:numSet(i,1),i) = data{i};
                end
            end
        else
            if stringDataFlag
                output = strings(maxElementLength, numCell); 
            else
                output = nan(maxElementLength, numCell); % create empty nan matrix for the case of different numSpikes in different channels
            end
            for i = 1:numCell
                if numElement(i,1)~=0
                    try
                        output(1:numElement(i,1),i) = data{i};
                    catch
                        output = nan;
                    end
                end
            end
        end
    end
end

end
