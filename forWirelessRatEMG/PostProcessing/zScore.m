function output = zScore(data,baselineParam,n)
%zScore Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(data)
    burstParam{i} = basicParam(data{i});
    z(i) = burstParam{i}.mean / baselineParam.std(n);
end

output = basicParameter(z);
output.z = z;

end

