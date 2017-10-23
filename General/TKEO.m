function [dataTKEO_abs_filtered] = TKEO(data,Fs)
%TKEO Output the TKEO data
%   [dataTKEO_abs_filtered] = TKEO(data,Fs,iter)

[rowData,colData] = size(data);
for n = 1:colData
    for i = 2:rowData-1
        dataTKEO(i,n) = data(i,n)^2 - data(i+1,n)*data(i-1,n);
    end
end

dataTKEO_abs = abs(dataTKEO);

dataTKEO_abs_filtered = filterData(dataTKEO_abs,0,15,Fs);
end

