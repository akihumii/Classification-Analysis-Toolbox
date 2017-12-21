function dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
%filterData Apply LowPass/HighPass/BandPass filter. Enter 0 if that
%particular filter is not applied. Enter both low and high cutoff
%frequency if a bandpass filter is being selected.
%   dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)

if nargin < 5
    notchFreq = 0;
end

% Skip the filters
skipHighPass = 0;
skipLowPass = 0;
skipNotchFilter = 0;

%% Built Filter
if highPassCutoffFreq ~= 0
    try
        [bHigh,aHigh] = butter(4,highPassCutoffFreq/(samplingFreq/2),'high'); % high pass filter
    catch
        warning('High pass cutoff frequency is not appropriate, no high pass filter is applied...')
        skipHighPass = 1;
    end
end
if lowPassCutoffFreq ~= 0
    try
        [bLow,aLow] = butter(4,lowPassCutoffFreq/(samplingFreq/2),'low'); % low pass filter
    catch
        warning('Low pass cutoff frequency is not appropriate, no low pass filter is applied...')
        skipLowPass = 1;
    end
end
if notchFreq ~= 0
    wo = notchFreq/(samplingFreq/2);  bw = wo/5; % notch filter
    try
        [bNotch,aNotch] = iirnotch(wo,bw);
    catch
        warning('Notch filter frequency is not appropriate, no notch filter is applied...')
        skipNotchFilter = 1;
    end
end

%% Apply Filter
[rowData, colData] = size(data);
if highPassCutoffFreq ~= 0 || lowPassCutoffFreq ~= 0
    if highPassCutoffFreq ~= 0 && lowPassCutoffFreq == 0
        if ~skipHighPass
            for j = 1:colData
                dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
            end
        end
        dataFilt = dataHPF;
        
    elseif highPassCutoffFreq == 0 && lowPassCutoffFreq ~= 0
        if ~skipLowPass
            for j = 1:colData
                dataLPF(:,j) = filtfilt(bLow,aLow,data(:,j)); % apply low pass filter
            end
        end
        dataFilt = dataLPF;
        
    else
        for j = 1:colData
            if ~skipHighPass
                dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
            else
                dataHPF(:,j) = data(:,j);
            end
            if ~skipLowPass
                dataBPF(:,j) = filtfilt(bLow,aLow,dataHPF(:,j)); % apply low pass filter
            else
                dataBPF(:,j) = dataHPF(:,j);
            end
        end
        dataFilt = dataBPF;
    end
else
    dataFilt = data; % no highPassFilter nor lowPassFilter is applied
end

if notchFreq ~= 0 && ~skipNotchFilter
    dataFilt = filtfilt(bNotch,aNotch,dataFilt); % apply notch filter
end
end

