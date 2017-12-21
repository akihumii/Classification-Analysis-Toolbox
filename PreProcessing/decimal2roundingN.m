function N = decimal2roundingN(number)
%decimal2roundingN Output the number of decimal places
%   N = decimal2roundingN(number)

a = 1;
N = 0;

while a-number > 0 
    a = a/10;
    N = N+1;
end

end

