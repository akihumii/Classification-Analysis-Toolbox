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
        dataAll
        dataRaw
        dataFiltered
        dataFFT
        dataDelta
        dataTKEO
        dataPCA
    end
    
    properties (Dependent)
    end
    
    %% Methods
    methods
        function data = classData(file,path,fileType, varargin)
            if nargin > 0
                data.file = file;
                data.path = path;
                data.fileType = fileType;
                [data.dataAll, data.time] = reconstructData(file, path, fileType);
                data.channel = 1:size(data.dataAll,2);
                data.fileName = naming(data.file);
                switch lower(data.fileType)
                    case 'intan'
                        data.samplingFreq = 30000;
                    case 'sylphx'
                        data.samplingFreq = 16671;
                    case 'sylphii'
                        data.samplingFreq = 16671;
                    case 'neutrino'
                        data.samplingFreq = 17500;
                    otherwise
                        error('Invalid fileType. Possible fileType: ''intan'', ''sylphX'', ''sylphII''')
                end
                %                 % For trimming
                %                 data.dataRaw = data.dataRaw(7*data.samplingFreq:end);
                %                 data.time = data.time(7*data.samplingFreq:end);
                if nargin == 4
                    clear data.channel
                    data.channel = varargin{1};
                end
                data.dataRaw = data.dataAll(:,data.channel);
            end
        end
        
        function data = filterData(data, targetName, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, varargin)
            if nargin == 6
                notchFreq = varargin{1};
                data.dataFiltered.values = filterData(data.(targetName), samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq);
            else
                notchFreq = nan;
                data.dataFiltered.values = filterData(data.(targetName), samplingFreq, highPassCutoffFreq, lowPassCutoffFreq);
            end
            data.dataFiltered.highPassCutoffFreq = highPassCutoffFreq;
            data.dataFiltered.lowPassCutoffFreq = lowPassCutoffFreq;
            data.dataFiltered.notchFreq = notchFreq;
            data.dataFiltered.samplingFreq = samplingFreq;
            data.dataFiltered.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = dataDifferentialSubtraction(data, targetName, channelRef)
            data.dataDelta = dataDifferentialSubtraction(data.(targetName), channelRef);
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
