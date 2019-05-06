function [dataTKEO_abs_filtered] = TKEO(data,samplingFreq)
%TKEO Output the TKEO data. Included all the steps except the trimming the
%middle parts of the baseline and the developed bursts
%   [dataTKEO_abs_filtered] = TKEO(data,Fs)

[rowData,colData] = size(data);

data = filterData(data,samplingFreq,10,500); % bandpass filter of 10-500 Hz

data = filterData(data,samplingFreq,30,300); % bandpass filter of 30-300 Hz

for n = 1:colData
    for i = 2:rowData-1
        dataTKEO(i-1,n) = data(i,n)^2 - data(i+1,n)*data(i-1,n);
    end
%     dataTKEO(1,n) = dataTKEO(2,n);
end

dataTKEO = [dataTKEO ; repmat(dataTKEO(end,:),2,1)];
    
dataTKEO_abs = abs(dataTKEO);

dataTKEO_abs_filtered = filterData(dataTKEO_abs,samplingFreq,0,50);
end


