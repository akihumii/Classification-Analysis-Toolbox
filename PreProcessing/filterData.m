function dataFilt = filterData(data, highPassCutoffFreq, lowPassCutoffFreq, Fs)
%filterData Apply LowPass/HighPass/BandPass filter. Enter 0 if that 
%particular filter is not applied. Enter both low and high cutoff
%frequency if a bandpass filter is being selected.
%   dataFilt = filterData(data, highPassCutoffFreq, lowPassCutoffFreq, Fs)

%% Built Filter
[rowData, colData] = size(data);

if highPassCutoffFreq~=0 && lowPassCutoffFreq~=0
    [bHigh,aHigh] = butter(4,highPassCutoffFreq/(Fs/2),'high');
    [bLow,aLow] = butter(4,lowPassCutoffFreq/(Fs/2),'low');
    for j = 1:colData
        dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j));
        dataBPF(:,j) = filtfilt(bLow,aLow,dataHPF(:,j));
    end
    
elseif highPassCutoffFreq==0
    [bLow,aLow] = butter(4,lowPassCutoffFreq/(Fs/2),'low');
    for j = 1:colData
        dataBPF(:,j) = filtfilt(bLow,aLow,data(:,j));
    end
    
elseif lowPassCutoffFreq==0
    [bHigh,aHigh] = butter(4,highPassCutoffFreq/(Fs/2),'high');
    for j = 1:colData
        dataBPF(:,j) = filtfilt(bHigh,aHigh,data(:,j));
    end
end

dataFilt = dataBPF;

end

