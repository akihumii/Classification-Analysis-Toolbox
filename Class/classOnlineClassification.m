classdef classOnlineClassification < matlab.System
    % For online classifiation 
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        classiferMdl
        threshold
        numOnsetBurst
        numOffsetBurst
        windowSize
        samplingFreq
        host
        port
        tcpipArg
        dataRaw
        dataTKEO
        dataFiltered
        readyDetect = 0;
        readyClassify = 0;
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        lengthTKEO = 13;
    end

    methods
        function setBasicParameters(obj,data)
            obj.threshold = data.thresholds;
            obj.numOnsetBurst = data.numStartConsecutivePoints;
            obj.numOffsetBurst = data.numEndConsecutivePoints;
            obj.samplingFreq = data.samplingFreq;
            obj.windowSize = setupMaxBurstLength(obj);
        end
        
        function setTcpip(obj,host,port,varargin)
            obj.host = host;
            obj.port = port;
            obj.tcpipArg = varargin;
        end
        
        function t = tcpip(obj)
            t = tcpip(obj.host,obj.port,obj.tcpipArg{:});
        end
        
        function readSample(obj,t)
            sample = fread(t, t.BytesAvailable);
            lengthData = length(obj.dataRaw);
            
            if lengthData < obj.lengthTKEO
                obj.dataRaw = [obj.dataRaw; sample]; % accumulate samples at the beginning
            else
                obj.readyDetect = 1;
                obj.dataRaw = fixRawData(obj,lengthData);
            end
        end
        
        function detectBurst(obj)
            if obj.readyDetect
                obj.dataTKEO = TKEO(obj.dataRaw,obj.samplingFreq);
                [obj.peaks,obj.locs] = triggerSpikeDetection(obj.dataTKEO,obj.threshold,0,obj.numOnsetBurst,0);
                obj.readyClassify = ~isempty(obj.peaks); % activate flag for classify
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                obj.features = featureExtraction(obj.dataFiltered,obj.samplingFreq);
                obj.predictClass = predict();
            end
        end
    end
    
    methods(Access = protected)        
        function output = setupMaxBurstLength(obj)
            output = max([obj.numOnsetBurst(:); obj.numOffsetBurst(:)]);
        end

        function dataRaw = fixRawData(obj,lengthData)
            if lengthData > obj.windowSize % to fix the burst length for processing
                dataRaw = [obj.dataRaw(2:end); sample];
            end
        end
    end
end
