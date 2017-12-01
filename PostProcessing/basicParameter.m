function output = basicParam(data)
%basicParam Summary of this function goes here
%   Detailed explanation goes here
data_mean = mean(data);
data_std = std(data);
data_stde = data_std/sqrt(length(data));

output.mean = data_mean;
output.std = data_std;
output.stde = data_stde;
end

