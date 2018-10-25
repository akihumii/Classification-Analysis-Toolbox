function filterCoeff = getFilterCoeff(samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
%GETFILTERCOEFF Get the coefficient to build a filter
%   filterCoeff = getFilterCoeff(samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)

%% Initialize
bHigh = 0;
aHigh = 0;
bLow = 0;
aLow = 0;
bNotch = 0;
aNotch = 0;

%% Get the coefficients
if highPassCutoffFreq ~= 0
    try
        [bHigh,aHigh] = butter(4,highPassCutoffFreq/(samplingFreq/2),'high'); % high pass filter
    catch
        warning('High pass cutoff frequency is not appropriate, no high pass filter is applied...')
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
    end
end

%% Output
filterCoeff = makeStruct(...
    bHigh, aHigh, bLow, aLow, bNotch, aNotch);

end

