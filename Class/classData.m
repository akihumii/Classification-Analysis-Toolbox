classdef classData
    % Reconstruct data and provide relavant information. fileType: intan,
    % sylphii, sylphx
    % function data = classData(file,path,fileType)
    %
    % function data = filterData(data, targetValue, targetName, lowCutoffFreq, highCutoffFreq, samplingFreq)
    % function data = fftDataConvert(data,targetValue, targetName,samplingFreq)
    % function data = noiseLevelDetection(data,targetValue,targetName)
    % function data = TKEO(data,targetValue,targetName,samplingFreq)
    % function data = pcaConverter(data,targetValue,targetName)
    
    %% Properties
    properties
        file
        path
        fileType
        fileName
        time
        samplingFreq
        channel
        noiseData
        dataRaw
        dataFiltered
        dataFFT
        dataTKEO
        dataPCA
    end
    
    properties (Dependent)
    end
    
    %% Methods
    methods
        function data = classData(file,path,fileType)
            if nargin > 0
                data.file = file;
                data.path = path;
                data.fileType = fileType;
                [data.dataRaw, data.time, data.channel] = reconstructData(file, path, fileType);
                data.fileName = naming(data.file);
                switch lower(data.fileType)
                    case 'intan'
                        data.samplingFreq = 30000;
                    case 'sylphx'
                        data.samplingFreq = 16671;
                    case 'sylphii'
                        data.samplingFreq = 16671;
                    otherwise
                        error('Invalid fileType. Possible fileType: ''intan'', ''sylphX'', ''sylphII''')
                end
%                 % For trimming
%                 data.dataRaw = data.dataRaw(7*data.samplingFreq:end);
%                 data.time = data.time(7*data.samplingFreq:end);
            end
        end
        
        function data = filterData(data, targetValue, targetName, highPassCutoffFreq, lowPassCutoffFreq, samplingFreq)
            data.dataFiltered.values = filterData(targetValue, highPassCutoffFreq, lowPassCutoffFreq, samplingFreq);
            data.dataFiltered.highPassCutoffFreq = highPassCutoffFreq;
            data.dataFiltered.lowPassCutoffFreq = lowPassCutoffFreq;
            data.dataFiltered.samplingFreq = samplingFreq;
            data.dataFiltered.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = fftDataConvert(data,targetValue, targetName,samplingFreq)
            [data.dataFFT.values, data.dataFFT.freqDomain] = ...
                fftDataConvert(targetValue, samplingFreq);
            data.dataFFT.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = noiseLevelDetection(data,targetValue,targetName)
            data.noiseData.values = noiseLevelDetection(targetValue);
            data.noiseData.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = TKEO(data,targetValue,targetName,samplingFreq)
            data.dataTKEO.values = TKEO(targetValue, samplingFreq);
            data.dataTKEO.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = pcaConverter(data,targetValue,targetName)
            data.dataPCA.values = pcaConverter(targetValue);
            data.dataPCA.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
    end
end
