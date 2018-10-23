classdef classOnlineClassification < matlab.System
    % For online classifiation 
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        predictClass = 0;
        threshold
        numOnsetBurst
        numOffsetBurst
        windowSize
        samplingFreq
        host
        port
        tcpipArg
        dataRaw
        highPassCutoffFreq = 500
        lowPassCutoffFreq = 30
        notchFreq = 50
        featureClassification; % corresponds to mean value
        classifierMdl
        numClass
%         dataTKEO
%         dataFiltered
        windowFull = 0;
        readyDetect = 0;
        readyClassify = 0;
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        lengthTKEO = 13;
        numChannel = 0;
        t
    end

    methods
        function setBasicParameters(obj,data)
            obj.threshold = data.thresholds;
            obj.numOnsetBurst = data.numStartConsecutivePoints;
            obj.numOffsetBurst = data.numEndConsecutivePoints;
            obj.samplingFreq = data.samplingFreq;
            obj.windowSize = setupMaxBurstLength(obj);
            obj.featureClassification = data.featureClassification;
            obj.classifierMdl = data.classifierMdl;
            obj.numClass = data.numClass; % including one class of resting state
        end
        
        function setTcpip(obj,host,port,varargin)
            obj.host = host;
            obj.port = port;
            obj.tcpipArg = varargin;
            getNumChannel(obj); % update the number of channels
        end
        
        function setInitialData(obj) % initialize data
            obj.dataRaw = cell(obj.numChannel,1);
%             obj.dataTKEO = cell(obj.numChannel,1);
%             obj.dataFiltered = cell(obj.numChannel,1);
        end
        
        function tcpip(obj)
            for i = 1:obj.numChannel
                obj.t{i,1} = tcpip(obj.host,obj.port(1,i),obj.tcpipArg{:});
            end
        end
        
        function openPort(obj)
            for i = 1:obj.numChannel
                fopen(obj.t(i,1));
                disp(['Open port ',num2str(ports),'...']);
            end
        end
        
        function closePort(obj)
            for i = 1:obj.numChannel
                fclose(obj.t(i,1));
                disp(['Close port ',num2str(ports),'...']);
            end
        end
        
        function readSample(obj)
            lengthData = length(obj.dataRaw{1,1});
            obj.readyDetect = lengthData > obj.lengthTKEO; % activate ready detect
            obj.windowFull = lengthData > obj.windowSize; % activate trimming of samples
            
            for i = 1:obj.numChannel
                sample = fread(obj.t{i,1}, obj.t{i,1}.BytesAvailable);
                
                obj.dataRaw{1,1} = [obj.dataRaw{1,1}; sample]; % accumulate samples at the beginning
                
                if obj.windowFull
                    obj.dataRaw{1,1}(1,1) = []; % remove the excess samples 
                end
            end
        end
        
        function detectBurst(obj)
            if obj.readyDetect
                for i = 1:obj.numChannel
                    dataTKEO = TKEO(obj.dataRaw{i,1},obj.samplingFreq);
                    [peaks,~] = triggerSpikeDetection(dataTKEO,obj.threshold(1,i),0,obj.numOnsetBurst(1,i),0);
                    if ~isnan(peaks)
                        obj.readyClassify = 1; % activate flag for classify
                        break % break the for loop whenever a burst is found
                    end
                end                               
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                features = cell(obj.numChannel,1);
                for i = 1:obj.numChannel
                    dataFiltered = filter(obj,i); % get the filtered data for each channel
                    features{i,1} = featureExtraction(dataFiltered,obj.samplingFreq);
                end
                features = cell2nanMat(features);
                obj.predictClass = predict(obj.classifierMdl, features);
            end
        end
    end
    
    
    
    methods(Access = protected)        
        function output = setupMaxBurstLength(obj)
            output = max([obj.numOnsetBurst(:); obj.numOffsetBurst(:)]);
        end
        
        function getNumChannel(obj)
            obj.numChannel = length(obj.port);
        end
        
        function dataFiltered = filter(obj,i)
            dataFiltered = filterData(obj.dataRaw{i,1},obj.samplingFreq,obj.highPassCutoffFreq,obj.lowPassCutoffFreq,obj.notchFreq);
        end
    end
end
