function [data, dataName, iter] = dataAnalysis(parameters)
%dataAnalysis Generate objects that describes each processed data
% input:    parameters: dataType,dataToBeFiltered,dataToBeFFT,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,channel,channelPair,samplingFreq,partialDataSelection,constraintWindow,neutrinoInputReferred,neutrinoBit,downSamplingFreq,saveOverlap,showOverlap,saveFFT,showFFT
% 
%   [data, dataName, iter] = dataAnalysis(parameters)

switch parameters.selectFile 
    case 1
        [files, path, iter] = selectFiles(); % select files to be analysed
    case 0
        [files, path, iter] = getCurrentFiles(); % select files in current path
    case 2
        [files, path, iter] = getCurrentFiles(parameters.specificTarget);
    case 3
        splittedStr = split(parameters.specificTarget);
        files = splittedStr(end);
        path = fullfile(splittedStr(1:end-1));
        iter = 1;
    otherwise
        error('Invalid option for selectFile...')
end
    

%% pre-allocation
data(iter,1) = classData; % pre-allocate object array
dataName = cell(iter,1);

%% Analyse Data
for i = 1:iter
    data(i,1) = classData(files{i},path,parameters);
    if parameters.channelPair ~= 0
        data(i,1) = dataDifferentialSubtraction(data(i,1),'dataRaw',parameters.channelPair); % create object 'data'
    end
    
    data(i,1) = rectifyData(data(i,1),'dataRaw'); % rectify data
    
    data(i,1) = filterData(data(i,1),parameters); % filter data
    
%     if parameters.saveOverlap || parameters.showOverlap
        data(i,1) = TKEO(data(i,1),'dataRaw'); % TKEO 
%     end
    
    if parameters.saveFFT || parameters.showFFT
        data(i,1) = fftDataConvert(data(i,1),parameters.dataToBeFFT); % do FFT
    end
        
    % pad zero
    if parameters.padZeroFlag
        data(i,1) = padZero(data(i,1));
    end
    
    dataName{i,1} = data(i,1).file;
    
    disp([data(i,1).file, ' has been analysed... '])
end

end

