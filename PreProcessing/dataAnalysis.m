function [data, dataName, iter] = dataAnalysis(dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef,samplingFreq,dataSelection,neutrinoInputRefer,decimateFactor)
%dataAnalysis Generate objects that describes each processed data
%   [data, dataName, iter] = dataAnalysis(dataType,dataToBeFiltered,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelRef,samplingFreq)
close all

[files, path, iter] = selectFiles(); % select files to be analysed

%% pre-allocation
data(iter,1) = classData; % pre-allocate object array
dataName = cell(iter,1);

%% Analyse Data
for i = 1:iter
    data(i,1) = classData(files{i},path,dataType,channel,samplingFreq,dataSelection,neutrinoInputRefer);
    if channelRef ~= 0
        data(i,1) = dataDifferentialSubtraction(data(i,1),'dataRaw',channelRef);
    end
    data(i,1) = rectifyData(data(i,1),'dataRaw');
    data(i,1) = filterData(data(i,1),dataToBeFiltered, data(i,1).samplingFreq, highPassCutoffFreq,lowPassCutoffFreq, notchFreq);
    data(i,1) = TKEO(data(i,1),'dataRaw',data(i,1).samplingFreq);
    data(i,1) = fftDataConvert(data(i,1),dataToBeFFT,data(i,1).samplingFreq);
    data(i,1) = decimateData(data(i,1),decimateFactor,[{'dataRaw'};{'dataFiltered'};{'dataTKEO'}]);
    dataName{i,1} = data(i,1).file;
    disp([data(i,1).file, ' has been analysed... '])
end

end

