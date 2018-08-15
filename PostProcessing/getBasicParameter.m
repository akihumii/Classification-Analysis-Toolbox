function output = getBasicParameter(data)
%basicParam Output the basic parameters, input must be vertical array.
% 
% output: mean, std, stde, max, min
% 
%   output = getBasicParameter(data)

output.mean = squeeze(mean(data,1));
output.std = squeeze(std(data,0,1));
output.stde = squeeze(output.std/sqrt(size(data,1)));
[maxValue,maxLoc] = max(data,[],1);
output.max = squeeze(maxValue);
output.Loc = squeeze(maxLoc);
[minValue,minLoc] = min(data,[],1);
output.min = squeeze(minValue);
output.minLoc = squeeze(minLoc);
output.raw = data;
end

