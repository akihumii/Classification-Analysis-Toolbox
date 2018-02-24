function output = getBasicParameter(data)
%basicParam Output the basic parameters.
% 
% output: mean, std, stde, max, min
% 
%   output = getBasicParameter(data)

output.mean = mean(data);
output.std = std(data);
output.stde = output.std/sqrt(length(data));
output.max = max(data);
output.min = min(data);
output.raw = data;
end

