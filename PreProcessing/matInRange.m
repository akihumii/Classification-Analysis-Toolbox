function output = matInRange(data,range)
%MATINRANGE Fill nan to the values that do not fall in the range
%   output = matInRange(data,range)

output = data;

output(output<range(1)) = nan;
output(output>range(2)) = nan;

end

