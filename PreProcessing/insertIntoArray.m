function output = insertIntoArray(element, mainArray, locs, axis)
%INSERTINTOARRAY Insert elements into matrix
% input: element: one and only one element to be inserted into array
%        mainArray: the main array to be inserted
%        locs: a binary array with the final length of inserted mainArray,
%              locations filled with 1 is the place to insert the element
%   output = insertIntoArray(element, mainArray, locs, axis)

if any(locs)
    if axis == 1
        if length(locs) < size(mainArray, 1)
            locsZeros = zeros(size(mainArray, 1), 1);
            locsZeros(locs) = 1;
            locs = locsZeros;
        end
    elseif axis == 2
        if length(locs) < size(mainArray, 1)
            locsZeros = zeros(size(mainArray, 1), 2);
            locsZeros(locs) = 1;
            locs = locsZeros;
        end
    else
        error('Invalid axis...')
    end
    
    locslocs = find(locs);
    numLocslocs = length(locslocs);
    
    locsTemp = 1 : locslocs(1)-1;
    
    if axis == 1
        output = mainArray(locsTemp, :);
        output = vertcat(output, element);
        
        for i = 1:numLocslocs-1
            output = vertcat(output, mainArray(locslocs(i)-(i-1) : locslocs(i+1)-(i+1),:));
            output = vertcat(output, element);
        end
        
        output = vertcat(output, mainArray(locslocs(end) - (length(locslocs)-1):end, :));
    elseif axis == 2        
        output = mainArray(:, locsTemp);
        output = horzcat(output, element);
        
        for i = 1:numLocslocs-1
            output = horzcat(output, mainArray(:, locslocs(i)-(i-1) : locslocs(i+1)-(i+1)));
            output = horzcat(output, element);
        end
        
        output = horzcat(output, mainArray(:, locslocs(end) - (length(locslocs)-1):end));
    end
else
    warning('No insertion has been done...')
    output = mainArray;
end
end
