function dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
%filterData Apply LowPass/HighPass/BandPass filter. Enter 0 if that
%particular filter is not applied. Enter both low and high cutoff
%frequency if a bandpass filter is being selected.
%   dataFilt = filterData(data, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)

if ~exist('butter', 'file')
    error('Please install Signal Processing Toolbox first...')
end

if nargin < 5
    notchFreq = 0;
end

%% Built Filter
filterCoeff = getFilterCoeff(samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq);


%% Apply Filter
[rowData, colData] = size(data);
if highPassCutoffFreq ~= 0 || lowPassCutoffFreq ~= 0
    if highPassCutoffFreq ~= 0 && lowPassCutoffFreq == 0
        try
            for j = 1:colData
                dataHPF(:,j) = filtfilt(filterCoeff.bHigh,filterCoeff.aHigh,data(:,j)); % apply high pass filter
            end
            dataFilt = dataHPF;
        catch
            warning('High pass cutoff frequency is not appropriate, no high pass filter is applied...')
            dataFilt = data;
        end
        
    elseif highPassCutoffFreq == 0 && lowPassCutoffFreq ~= 0
        try
            for j = 1:colData
                dataLPF(:,j) = filtfilt(filterCoeff.bLow,filterCoeff.aLow,data(:,j)); % apply low pass filter
            end
            dataFilt = dataLPF;
        catch
        warning('Low pass cutoff frequency is not appropriate, no low pass filter is applied...')
            dataFilt = data;
        end
        
    else
        for j = 1:colData
            try
                dataHPF(:,j) = filtfilt(filterCoeff.bHigh,filterCoeff.aHigh,data(:,j)); % apply high pass filter
            catch
                warning('High pass cutoff frequency is not appropriate, no high pass filter is applied...')                
                dataHPF(:,j) = data(:,j);
            end
            try
                dataBPF(:,j) = filtfilt(filterCoeff.bLow,filterCoeff.aLow,dataHPF(:,j)); % apply low pass filter
            catch
                warning('Low pass cutoff frequency is not appropriate, no low pass filter is applied...')
                try
                    dataBPF(:,j) = dataHPF(:,j);
                catch
                    dataBPF(:,j) = data(:,j);
                end
            end
        end
        try
            dataFilt = dataBPF;
        catch
            dataFilt = data;
        end
    end
else
    dataFilt = data; % no highPassFilter nor lowPassFilter is applied
end

if notchFreq ~= 0 
    try
        dataFilt = filtfilt(filterCoeff.bNotch,filterCoeff.aNotch,dataFilt); % apply notch filter
    catch
        warning('Notch filter frequency is not appropriate, no notch filter is applied...')
    end
end
end

