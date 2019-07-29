function output = insertIntoArray(subArray, mainArray, locs, axis)
%INSERTINTOARRAY Insert elements into matrix
%   output = insertIntoArray(subArray, mainArray, locs, axis)

if any(length(locs) >= size(mainArray, axis) & any(locs))
    locslocs = find(locs);
    numLocslocs = length(locslocs);
    
    locsTemp = 1 : locslocs(1)-1;
    if axis == 1
        output = mainArray(locsTemp, :);
        output = vertcat(output, subArray);
        
        for i = 1:numLocslocs-1
            output = vertcat(output, mainArray(locslocs(i)-(i-1) : locslocs(i+1)-(i+1),:));
            output = vertcat(output, subArray);
        end
        
        output = vertcat(output, mainArray(locslocs(end) - (length(locslocs)-1):end, :));
    end
else
    output = mainArray;
end
end

