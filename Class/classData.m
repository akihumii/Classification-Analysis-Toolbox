classdef classData
    % Reconstruct data and provide relavant information. fileType: intan,
    % sylphii, sylphx
    % function data = classData(file,path,fileType)
    %
    % data = filterData(data, targetName, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
    % data = fftDataConvert(data, targetName,samplingFreq)
    % data = noiseLevelDetection(data,targetValue,targetName)
    % data = TKEO(data,targetValue,targetName,samplingFreq)
    % data = pcaConverter(data,targetValue,targetName)
    
    %% Properties
    properties
        file
        path
        fileType
        fileName
        time
        samplingFreq
        channel
        channelRef % reference channel for differential data
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
        function data = classData(file,path,fileType,channel,samplingFreq)
            if nargin > 0
                data.file = file;
                data.path = path;
                data.fileType = fileType;
                if samplingFreq == 0
                    switch lower(data.fileType)
                        case 'intan'
                            data.samplingFreq = 30000;
                        case 'sylphx'
                            data.samplingFreq = 16671;
                        case 'sylphii'
                            data.samplingFreq = 16671;
                        case 'neutrino'
                            data.samplingFreq = 3e6/14/12;
                        otherwise
                            error('Invalid dataType. Configurable dataType: ''Neutrino'', ''intan'', ''sylphX'', ''sylphII''')
                    end
                else
                    data.samplingFreq = samplingFreq;
                end
                [data.dataAll, data.time] = reconstructData(file, path, fileType);
                data.fileName = naming(data.file);
                %                 % For trimming
                %                 data.dataRaw = data.dataRaw(7*data.samplingFreq:end);
                %                 data.time = data.time(7*data.samplingFreq:end);
                data.channel = channel;
                data.dataRaw = data.dataAll(:,data.channel);
            end
        end
        
        function data = dataDifferentialSubtraction(data, targetName, channelRef)
            channelRefLocs = find(data.channel == channelRef);
            data.dataDelta = dataDifferentialSubtraction(data.(targetName), channelRefLocs);
            data.channelRef = channelRef;
        end
        
        function data = filterData(data, targetName, samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq)
            data.dataFiltered.values = filterData(data.(targetName), samplingFreq, highPassCutoffFreq, lowPassCutoffFreq, notchFreq);
            data.dataFiltered.highPassCutoffFreq = highPassCutoffFreq;
            data.dataFiltered.lowPassCutoffFreq = lowPassCutoffFreq;
            data.dataFiltered.notchFreq = notchFreq;
            data.dataFiltered.samplingFreq = samplingFreq;
            data.dataFiltered.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = fftDataConvert(data,targetName,samplingFreq)
            if isequal(targetName,'dataFiltered')
                targetName = [{'dataFiltered'};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(data,targetName);
            [data.dataFFT.values, data.dataFFT.freqDomain] = ...
                fftDataConvert(dataValue, samplingFreq);
            data.dataFFT.dataBeingProcessed = dataName;
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
