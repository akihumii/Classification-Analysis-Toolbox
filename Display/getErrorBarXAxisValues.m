function xAxis = getErrorBarXAxisValues(numBar,numClass)
%errorBarXValues Create an array of x axis values of errorbar 
% 
% input:    numBar: number of bar in total
%           numClass: type of class (different colors ones)
% 
%   xAxis = errorBarXAxisValues(numBar,numClass)

xAxis = transpose(1:numBar);

xAxis = repmat(xAxis,1,numClass);

middleNumber = floor(numClass/2);
difference = 0.3; % difference from the whole number

if logical(mod(numClass,2)) % odd number
    array = -middleNumber : middleNumber;
    skip = difference * array;
else % even number
    array = (-middleNumber+0.5) : (middleNumber-0.5);
    skip = difference * array;
end

xAxis = xAxis + repmat(skip,numBar,1);

end

