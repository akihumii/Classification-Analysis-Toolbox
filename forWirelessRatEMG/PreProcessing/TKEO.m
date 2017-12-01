function [dataTKEO_abs_filtered] = TKEO(data,Fs,iter)
%TKEO Summary of this function goes here
%   Detailed explanation goes here

[rowData,colData] = size(data);
for n = 1:colData
    for i = 2:rowData-1
        dataTKEO(i,n) = data(i,n)^2 - data(i+1,n)*data(i-1,n);
    end
end

dataTKEO_abs = abs(dataTKEO);

dataTKEO_abs_filtered = filterData(dataTKEO_abs,0,15,Fs,iter);
end

