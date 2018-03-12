function output = getBasicParameter(data)
%basicParam Output the basic parameters.
% 
% output: mean, std, stde, max, min
% 
%   output = getBasicParameter(data)

output.mean = mean(data,1);
output.std = std(data,0,1);
output.stde = output.std/sqrt(size(data,1));
[output.max,output.maxLoc] = max(data,[],1);
[output.min,output.minLoc] = min(data,[],1);
output.raw = data;
end

