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
        analysedDataTiming
        samplingFreq
        decimateFactor
        channel
        channelPair % reference channel for differential data
        noiseData
        dataAll
        dataRaw
        dataRectified
        dataFiltered
        dataFFT
        dataDifferential
        dataTKEO
        dataPCA
    end
    
    properties (Dependent)
    end
    
    %% Methods
    methods
        function data = classData(file,path,parameters)
            % input: parameters: fileType,neutrinoBit,channel,samplingFreq,neutrinoInputReferred,partialDataSelection,constraintWindow,downSamplingFreq
            if nargin > 0
                data.file = file;
                data.path = path;
                data.fileType = parameters.dataType;
                if parameters.samplingFreq == 0
                    switch lower(data.fileType)
                        case 'intan'
                            data.samplingFreq = 20000;
                        case 'sylphx'
                            data.samplingFreq = 1000;
                        case 'sylphii'
                            data.samplingFreq = 1798.2;
                        case 'neutrino'
                            data.samplingFreq = 3e6/14/12;
                        case 'neutrino2'
                            data.samplingFreq = 3e6/14/12;
                        otherwise
                            error('Invalid dataType. Configurable dataType: ''Neutrino'', ''intan'', ''sylphX'', ''sylphII''')
                    end
                else
                    data.samplingFreq = parameters.samplingFreq;
                end
                [data.dataAll, data.time] = reconstructData(file, path, parameters.dataType, parameters.neutrinoBit, parameters.neutrinoInputReferred);
                
                % decimate signal
                if parameters.downSamplingFreq ~= 0 
                    data.dataAll = decimateData(data.dataAll,parameters.downSamplingFreq,data.samplingFreq);
                    data.time = data.time * parameters.downSamplingFreq / data.samplingFreq; % change the unit to suit the downsampled one
                    data.time = decimateData(data.time,parameters.downSamplingFreq,data.samplingFreq);
                    data.samplingFreq = parameters.downSamplingFreq; % change the samplingFreq to the downSamplingFreq
                end
                
                % get interested channel
                data.fileName = naming(data.file);
                data.channel = parameters.channel;
                data.channelPair = parameters.channel';
                if parameters.channel > size(data.dataAll,2)
                    error('Error found in User Input: Selected channel is not existed')
                end
                data.dataRaw = data.dataAll(:,data.channel);
                
                % average data
                if parameters.channelAveragingFlag
                    data = averageData(data, parameters.channelAveraging);
                end
                
                % for trimming
                if parameters.partialDataSelection
                    partialDataInfo = selectPartialData(data.time,data.dataRaw,data.fileName,data.path,parameters.constraintWindow,data.samplingFreq);
                    data.dataRaw = partialDataInfo.partialData;
                    data.time = data.time(partialDataInfo.startLocs:partialDataInfo.endLocs);
                    data.analysedDataTiming = [data.time(1)/data.samplingFreq,data.time(end)/data.samplingFreq;partialDataInfo.startLocs,partialDataInfo.endLocs]; % starting time and end time of the data that is being analysed
                end
            end
        end
        
        function data = rectifyData(data,targetName)
            data.dataRectified = filterData(data.(targetName),data.samplingFreq,1,0,0);
            data.dataRectified = abs(data.dataRectified);
        end
        
        function data = dataDifferentialSubtraction(data, targetName, channelPair)
            [~,channelRefLocs] = ismember(channelPair',data.channel); % get the locations of the channel pairs in all the channels
            data.dataDifferential = dataDifferentialSubtraction(data.(targetName), channelRefLocs); % subtract according to 1-2, 3-4, etc...
            data.channelPair = channelPair;
        end
        
        function data = filterData(data, parameters)
            % input: parameters: highPassCutoffFreq, lowPassCutoffFreq, notchFreq
            data.dataFiltered.values = filterData(data.(parameters.dataToBeFiltered), data.samplingFreq, parameters.highPassCutoffFreq, parameters.lowPassCutoffFreq, parameters.notchFreq);
            data.dataFiltered.highPassCutoffFreq = parameters.highPassCutoffFreq;
            data.dataFiltered.lowPassCutoffFreq = parameters.lowPassCutoffFreq;
            data.dataFiltered.notchFreq = parameters.notchFreq;
            data.dataFiltered.dataBeingProcessed = parameters.dataToBeFiltered;
            errorShow(parameters.dataToBeFiltered, 'dataToBeFiltered', 'char');
        end
        
        function data = fftDataConvert(data,targetName)
            if isequal(targetName,'dataFiltered') || isequal(targetName,'dataTKEO')
                targetName = [{targetName};{'values'}];
            end
            [dataValue, dataName] = loadMultiLayerStruct(data,targetName);
            [data.dataFFT.values, data.dataFFT.freqDomain] = ...
                fftDataConvert(dataValue, data.samplingFreq);
            if isequal(dataName,'dataFilteredvalues')
                data.dataFFT.dataBeingProcessed = [dataName,' (',num2str(data.dataFiltered.highPassCutoffFreq),'-',num2str(data.dataFiltered.lowPassCutoffFreq),')'];
            else
                data.dataFFT.dataBeingProcessed = dataName;
            end
        end
        
        function data = noiseLevelDetection(data,targetValue,targetName)
            data.noiseData.values = noiseLevelDetection(targetValue);
            data.noiseData.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = TKEO(data,targetName)
            [dataValue, dataName] = loadMultiLayerStruct(data,targetName);
            data.dataTKEO.values = TKEO(dataValue, data.samplingFreq);
            data.dataTKEO.dataBeingProcessed = dataName;
        end
        
        function data = pcaConverter(data,targetValue,targetName)
            data.dataPCA.values = pcaConverter(targetValue);
            data.dataPCA.dataBeingProcessed = targetName;
            errorShow(targetName, 'targetName', 'char');
        end
        
        function data = padZero(data)
            counterRaw = data.dataAll(:,12);
            data.dataAll = editData(data.dataAll,counterRaw,0,3);
            data.dataRaw = editData(data.dataRaw,counterRaw,0,3);            
            data.dataRectified = editData(data.dataRectified,counterRaw,0,3);
            data.dataFiltered.values = editData(data.dataFiltered.values,counterRaw,0,3);    
            data.dataTKEO.values = editData(data.dataTKEO.values,counterRaw,0,3);           
            data.time = 1:size(data.dataAll,1);
        end
        
        function data = omitPeriodicData(data, parameters)
            windowSize = parameters.dataPeriodicOmitWindowSize * data.samplingFreq;
            period = 1/parameters.dataPeriodicOmitFrequency * data.samplingFreq;
            startingPoint = parameters.dataPeriodicOmitStartingPoint * data.samplingFreq;
            data.time = transpose(omitPeriodicData(data.time', windowSize, period, startingPoint));
            data.dataRaw = omitPeriodicData(data.dataRaw, windowSize, period, startingPoint);
            data.dataRectified = omitPeriodicData(data.dataRectified, windowSize, period, startingPoint);
            data.dataFiltered.values = omitPeriodicData(data.dataFiltered.values, windowSize, period, startingPoint);
            data.dataTKEO.values = omitPeriodicData(data.dataTKEO.values, windowSize, period, startingPoint);
        end

        
    end
    
    methods(Access = protected)
        function data = averageData(data, channels)
            data.channel = [];
            data.dataRaw = [];
            for i = 1:length(channels)
                data.channel(1,i) = channels{i,1}(1,1);
                data.dataRaw(:,i) = mean(data.dataAll(:, channels{i,1}), 2);
            end
            data.channelPair = data.channel';
        end
    end
end
