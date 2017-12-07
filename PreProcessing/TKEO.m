function [dataTKEO_abs_filtered] = TKEO(data,samplingFreq)
%TKEO Output the TKEO data. Included all the steps except the trimming the
%middle parts of the baseline and the developed bursts
%   [dataTKEO_abs_filtered] = TKEO(data,Fs,iter)

[rowData,colData] = size(data);

data = filterData(data,samplingFreq,10,500);

data = filterData(data,samplingFreq,30,300);

dataTKEO = zeros(rowData,1);
dataTKEO(end,1) = data(end,1);

for n = 1:colData
    for i = 2:rowData-1
        dataTKEO(i,n) = data(i,n)^2 - data(i+1,n)*data(i-1,n);
    end
end

dataTKEO_abs = abs(dataTKEO);

dataTKEO_abs_filtered = filterData(dataTKEO_abs,samplingFreq,0,50);
end


