function [f1,f2] = getFactors(number)
%getFactors Get the two factors that the multiplication is equal to number
%   
%       [f1,f2] = getFactors(number)

temp = floor(sqrt(number));

while mod(number,temp) ~= 0
    temp = temp - 1;
end

f1 = temp;
f2 = number / temp;

end

