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
        decimateFactor
        channel
        channelRef % reference channel for differential data
        noiseData
        dataAll
        dataRaw
        dataRectified
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
        function data = classData(file,path,fileType,channel,samplingFreq,dataSelection,neutrinoInputRefer)
            if nargin > 0
                data.file = file;
                data.path = path;
                data.fileType = fileType;
                if samplingFreq == 0
                    switch lower(data.fileType)
                        case 'intan'
                            data.samplingFreq = 20000;
                        case 'sylphx'
                            data.samplingFreq = 16671;
                        case 'sylphii'
                            data.samplingFreq = 16671;
                        case 'neutrino'
                            data.samplingFreq = 3e6/14/12;
                        case 'neutrino2'
                            data.samplingFreq = 3e6/14/12;
                        otherwise
                            error('Invalid dataType. Configurable dataType: ''Neutrino'', ''intan'', ''sylphX'', ''sylphII''')
                    end
                else
                    data.samplingFreq = samplingFreq;
                end
                data.samplingFreq = data.samplingFreq; % down sampling
                [data.dataAll, data.time] = reconstructData(file, path, fileType, neutrinoInputRefer);
                data.fileName = naming(data.file);
                data.channel = channel;
                if channel > size(data.dataAll,2)
                    error('Error found in User Input: Selected channel is not existed')
                end
                data.dataRaw = data.dataAll(:,data.channel);
                % for trimming
                if ~isempty(dataSelection)
                    locsStart = dataSelection(1) * data.samplingFreq;
                    locsEnd = dataSelection(2) * data.samplingFreq;
                    data.dataRaw = data.dataRaw(locsStart:locsEnd,:);
                    data.time = data.time(locsStart:locsEnd);
                    data.time = data.time - data.time(1) + 1;
                end
            end
        end
        
        function data = rectifyData(data,targetName)
            data.dataRectified = filterData(data.(targetName),data.samplingFreq,1,0,0);
            data.dataRectified = abs(data.dataRectified);
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
        
        function data = TKEO(data,targetName,samplingFreq)
            [dataValue, dataName] = loadMultiLayerStruct(data,targetName);
            data.dataTKEO.values = TKEO(dataValue, samplingFreq);
            data.dataTKEO.dataBeingProcessed = dataName;
        end
        
        function data = pcaConverter(data,targetValue,targetName)
            data.dataPCA.values = pcaConverter(targetValue);
            data.dataPCA.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = decimateData(data,decimateFactor,targetName) % downsampling the targetName's values and the samplingFreq
            data.decimateFactor = decimateFactor;
            numField = length(targetName);
            for i = 1:numField
                if isequal(targetName{i,1},'dataFiltered') || isequal(targetName{i,1},'dataTKEO')
                    targetNameTemp = [targetName(i,1);{'values'}];
                    [dataValue, dataName] = loadMultiLayerStruct(data,targetNameTemp);
                    data.(targetName{i,1}).values = decimateData(dataValue,decimateFactor);
                else
                    targetNameTemp = targetName{i,1};
                    [dataValue, dataName] = loadMultiLayerStruct(data,targetNameTemp);
                    data.(targetName{i,1}) = decimateData(dataValue,decimateFactor);
                end
            end
            data.time = decimateData(data.time,decimateFactor);
            data.samplingFreq = data.samplingFreq / decimateFactor;
        end
    end
end
