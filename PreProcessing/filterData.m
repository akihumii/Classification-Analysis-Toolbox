function dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, varargin)
%filterData Apply LowPass/HighPass/BandPass filter. Enter 0 if that 
%particular filter is not applied. Enter both low and high cutoff
%frequency if a bandpass filter is being selected.
%   dataFilt = filterData(data, highPassCutoffFreq, lowPassCutoffFreq, Fs)

%% Built Filter
[bHigh,aHigh] = butter(4,highPassCutoffFreq/(samplingFreq/2),'high');
[bLow,aLow] = butter(4,lowPassCutoffFreq/(samplingFreq/2),'low');
if nargin == 5
    notchFreq = varargin{1};
    wo = notchFreq/(samplingFreq/2);  bw = wo/35;
    [bNotch,aNotch] = iirnotch(wo,bw);
end

%% Apply Filter
[rowData, colData] = size(data);

if highPassCutoffFreq~=0 && lowPassCutoffFreq~=0
    for j = 1:colData
        dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
        dataBPF(:,j) = filtfilt(bLow,aLow,dataHPF(:,j)); % apply low pass filter
    end
    
    dataFilt = dataBPF;
    
elseif highPassCutoffFreq==0
    for j = 1:colData
        dataLPF(:,j) = filtfilt(bLow,aLow,data(:,j)); % apply low pass filter
    end
    
    dataFilt = dataLPF;
    
elseif lowPassCutoffFreq==0
    for j = 1:colData
        dataHPF(:,j) = filtfilt(bHigh,aHigh,data(:,j)); % apply high pass filter
    end
    
    dataFilt = dataHPF;
end

if nargin == 5
    dataFilt = filtfilt(bNotch,aNotch,dataFilt); % applly notch filter
end


end

