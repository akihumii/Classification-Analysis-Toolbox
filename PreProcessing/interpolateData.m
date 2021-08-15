function output = interpolateData(data,locsNew)
%INTERPOLATEDATA Interpolate data to more data points
% input: data:  1-D: the values
%               2-D: the locsOrig
%   Detailed explanation goes here
data = squeeze(data);
values = data(:,1);
if size(data,2) == 1
    locsOld = 1:numel(data);
else
    locsOld = data(:,2);
end

steps = (locsOld(end) - locsOld(1)) / (numel(locsNew) * numel(locsOld));
locsAll = locsOld(1) : steps : locsOld(end);

output = interp1(locsOld, values, locsAll);

end

