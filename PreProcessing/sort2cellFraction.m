function output = sort2cellFraction(data,numElement)
%sort2cellFraction Sort the data into different cells contains numElement
%elements in a column. The last cell will contain the remaining elements.
% 
% input:    data:   an column vector of data
%           numElement: number of element in one cell
% 
%   output = sort2cellFraction(data,numElement)

numCell = floor(length(data) / numElement) + 1;

for i = 1:numCell
    if i*numElement <= length(data)
        output{i,1} = data(((i-1)*numElement+1) : i*numElement);
    else
        output{i,1} = data(((i-1)*numElement+1) : end);
    end 
end

end

