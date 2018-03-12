function [data, dataName] = dataAnalysis(dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelPair,samplingFreq,partialDataSelection,constraintWindow,neutrinoInputReferred,neutrinoBit,decimateFactor,saveOverlap,showOverlap,saveFFT,showFFT)
%dataAnalysis Generate objects that describes each processed data
%   [data, dataName, iter] = dataAnalysis(dataType,dataToBeFiltered,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef,samplingFreq,,partialDataSelection,constraintWindow,neutrinoInputReferred,decimateFactor,saveOverlap,showOverlap,saveFFT,showFFT)

%% pre-allocation
data = classData; % pre-allocate object array
dataName = cell(1,1);

%% Analyse Data
data = classData(dataType,neutrinoBit,channel,samplingFreq,neutrinoInputReferred,partialDataSelection,constraintWindow);
if channelPair ~= 0
    data = dataDifferentialSubtraction(data,'dataRaw',channelPair); % create object 'data'
end

data = rectifyData(data,'dataRaw'); % rectify data

data = filterData(data,dataToBeFiltered, data.samplingFreq, highPassCutoffFreq,lowPassCutoffFreq, notchFreq); % filter data

if saveOverlap || showOverlap
    data = TKEO(data,'dataRaw',data.samplingFreq); % TKEO
end

if saveFFT || showFFT
    data = fftDataConvert(data,dataToBeFFT,data.samplingFreq); % do FFT
end

if decimateFactor > 1
    data = decimateData(data,decimateFactor,[{'dataRaw'};{'dataFiltered'};{'dataRectified'};{'dataTKEO'}]); % decimate data
end

dataName{1,1} = data.file;

disp([data.file, ' has been analysed... '])

end

