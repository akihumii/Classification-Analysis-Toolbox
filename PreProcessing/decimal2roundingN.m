function N = decimal2roundingN(number)
%decimal2roundingN Output the number of decimal places
%   N = decimal2roundingN(number)

number = num2str(number);

while isequal(number(end),'0')
    number = number(1:end-1);
end

while isequal(number(1),'0')
    number = number(2:end);
end

N = length(number)-1;

end

