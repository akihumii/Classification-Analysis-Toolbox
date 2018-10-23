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
        overlapWindowSize
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
        readyClassify = 0;
    end
    
    properties(DiscreteState)
        
    end
    
    % Pre-computed constants
    properties(Access = private)
        lengthTKEO = 13;
        numChannel = 0;
        t
        stepRead
        startOverlapping = 0;
    end
    
    methods
        function setBasicParameters(obj,data,parameters)
            obj.threshold = data.thresholds;
            obj.numOnsetBurst = data.numStartConsecutivePoints;
            obj.numOffsetBurst = data.numEndConsecutivePoints;
            obj.samplingFreq = data.samplingFreq;
            %             obj.windowSize = setupMaxBurstLength(obj);
            obj.windowSize = 50;
            obj.featureClassification = data.featureClassification;
            obj.classifierMdl = data.classifierMdl;
            obj.numClass = data.numClass; % including one class of resting state
            
            obj.overlapWindowSize = parameters.overlapWindowSize;
            
            updateStepRead(obj); % update some constants
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
                fopen(obj.t{i,1});
                disp(['Open port ',num2str(obj.port),'...']);
            end
        end
        
        function closePort(obj)
            for i = 1:obj.numChannel
                fclose(obj.t{i,1});
                disp(['Close port ',num2str(obj.port),'...']);
            end
        end
        
        function readSample(obj)
            for i = 1:obj.numChannel
                if ~obj.startOverlapping
                    for j = 1:obj.stepRead:obj.windowSize
                        obj.dataRaw{i,1} = [obj.dataRaw{i,1} ; fread(obj.t{i,1}, obj.stepRead, 'double')];
                    end
                else
                    for j = 1:obj.stepRead:obj.overlapWindowSize
                        sample = fread(obj.t{i,1}, obj.stepRead, 'double');
                    obj.dataRaw{i,1} = fixWindow(obj,obj.dataRaw{i,1},sample);
                    end
                end
                
                obj.dataRaw{i,1}
            end
            obj.startOverlapping = 1;
        end
        
        function detectBurst(obj)
            for i = 1:obj.numChannel
                dataTKEO = TKEO(obj.dataRaw{i,1},obj.samplingFreq);
                [peaks,~] = triggerSpikeDetection(dataTKEO,obj.threshold(1,i),0,obj.numOnsetBurst(1,i),0);
                if ~isnan(peaks)
                    obj.readyClassify = 1 % activate flag for classify
                    break % break the for loop whenever a burst is found
                end
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                features = cell(obj.numChannel,1);
                for i = 1:obj.numChannel
                    dataFiltered = filter(obj,i); % get the filtered data for each channel
                    featuresTemp = featureExtraction(dataFiltered,obj.samplingFreq);
                    features(1,i) = featuresTemp.areaUnderCurve;
                end
                obj.predictClass = predict(obj.classifierMdl, features);
                
                obj.readyClassify = 0 % to deactivate the readyClassify after the prediction
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
        
        function output = fixWindow(obj,dataRaw,sample)
            output = [dataRaw(obj.stepRead+1 : end, 1) ; sample];
        end
        
        function updateStepRead(obj)
            for i = 50:-10:1
                if ~mod(obj.windowSize,i)
                    break
                end
            end
            obj.stepRead = i;
        end
    end
end
