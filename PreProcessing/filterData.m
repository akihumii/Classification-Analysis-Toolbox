function dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
%filterData Apply LowPass/HighPass/BandPass filter. Enter 0 if that
%particular filter is not applied. Enter both low and high cutoff
%frequency if a bandpass filter is being selected.
%   dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)

%% Built Filter
if highPassCutoffFreq ~= 0
    [bHigh,aHigh] = butter(4,highPassCutoffFreq/(samplingFreq/2),'high'); % high pass filter
end
if lowPassCutoffFreq ~= 0
    [bLow,aLow] = butter(4,lowPassCutoffFreq/(samplingFreq/2),'low'); % low pass filter
end
if notchFreq ~= 0
    wo = notchFreq/(samplingFreq/2);  bw = wo/5; % notch filter
    [bNotch,aNotch] = iirnotch(wo,bw);
end

%% Apply Filter
[rowData, colData] = size(data);
if highPassCutoffFreq ~= 0 || lowPassCutoffFreq ~= 0
    if highPassCutoffFreq ~= 0 && lowPassCutoffFreq == 0
        for j = 1:colData
            dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
        end
        dataFilt = dataHPF;
        
    elseif highPassCutoffFreq == 0 && lowPassCutoffFreq ~= 0
        for j = 1:colData
            dataLPF(:,j) = filtfilt(bLow,aLow,data(:,j)); % apply low pass filter
        end
        dataFilt = dataLPF;
        
    else
        for j = 1:colData
            dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
            dataBPF(:,j) = filtfilt(bLow,aLow,dataHPF(:,j)); % apply low pass filter
        end
        dataFilt = dataBPF;
    end
else
    dataFilt = data; % no highPassFilter nor lowPassFilter is applied
end

if notchFreq ~= 0
    dataFilt = filtfilt(bNotch,aNotch,dataFilt); % apply notch filter
end
end

