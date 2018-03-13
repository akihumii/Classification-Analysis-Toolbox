function [data, dataName, iter] = dataAnalysis(dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelPair,samplingFreq,partialDataSelection,constraintWindow,neutrinoInputReferred,neutrinoBit,downSamplingFreq,saveOverlap,showOverlap,saveFFT,showFFT)
%dataAnalysis Generate objects that describes each processed data
%   [data, dataName, iter] = dataAnalysis(dataType,dataToBeFiltered,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef,samplingFreq,,partialDataSelection,constraintWindow,neutrinoInputReferred,decimateFactor,saveOverlap,showOverlap,saveFFT,showFFT)

[files, path, iter] = selectFiles(); % select files to be analysed

%% pre-allocation
data(iter,1) = classData; % pre-allocate object array
dataName = cell(iter,1);

%% Analyse Data
for i = 1:iter
    data(i,1) = classData(files{i},path,dataType,neutrinoBit,channel,samplingFreq,neutrinoInputReferred,partialDataSelection,constraintWindow,downSamplingFreq);
    if channelPair ~= 0
        data(i,1) = dataDifferentialSubtraction(data(i,1),'dataRaw',channelPair); % create object 'data'
    end
    
    data(i,1) = rectifyData(data(i,1),'dataRaw'); % rectify data
    
    data(i,1) = filterData(data(i,1),dataToBeFiltered, data(i,1).samplingFreq, highPassCutoffFreq,lowPassCutoffFreq, notchFreq); % filter data
    
    if saveOverlap || showOverlap
        data(i,1) = TKEO(data(i,1),'dataRaw',data(i,1).samplingFreq); % TKEO 
    end
    
    if saveFFT || showFFT
        data(i,1) = fftDataConvert(data(i,1),dataToBeFFT,data(i,1).samplingFreq); % do FFT
    end
        
    dataName{i,1} = data(i,1).file;
    
    disp([data(i,1).file, ' has been analysed... '])
end

end

