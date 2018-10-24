classdef classOnlineClassification < matlab.System
    % For online classifiation
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    % Public, tunable properties
    properties
        predictClass = 0;
        thresholds
        numStartConsecutivePoints
        numEndConsecutivePoints
        windowSize = 200
        overlapWindowSize
        samplingFreq
        host
        port
        tcpipArg
        dataRaw = zeros(0,1)
        highPassCutoffFreq = 500
        lowPassCutoffFreq = 30
        notchFreq = 50
        featureClassification; % corresponds to mean value
        classifierMdl
        numClass
        readyClassify = 0
    end
    
    properties(DiscreteState)
        
    end
    
    % Pre-computed constants
    properties(Access = private)
        t
        stepRead
        startOverlapping = 0
    end
    
    methods
        function setBasicParameters(obj,data,parameters)
            fieldNames = fieldnames(data);
            numField = length(fieldNames);
            for i = 1:numField
                obj.(fieldNames{i,1}) = data.(fieldNames{i,1});
            end
            
            obj.overlapWindowSize = parameters.overlapWindowSize;
            
            updateStepRead(obj); % update the step size to store the data from Qt
        end
        
        function setTcpip(obj,host,port,varargin)
            obj.host = host;
            obj.port = port;
            obj.tcpipArg = varargin;
        end
        
%         function setInitialData(obj) % initialize data
%             obj.dataRaw = cell(obj.numChannel,1);
%             %             obj.dataTKEO = cell(obj.numChannel,1);
%             %             obj.dataFiltered = cell(obj.numChannel,1);
%         end
        
        function tcpip(obj)
            obj.t = tcpip(obj.host,obj.port,obj.tcpipArg{:});
        end
        
        function openPort(obj)
            fopen(obj.t);
            disp(['Open port ',num2str(obj.port),'...']);
        end
        
        function closePort(obj)
            for i = 1:obj.numChannel
                fclose(obj.t{i,1});
                disp(['Close port ',num2str(obj.port),'...']);
            end
        end
        
        function readSample(obj)
            if ~obj.startOverlapping
                for j = 1:obj.stepRead:obj.windowSize % store windowSize of data to make it full at the first time
                    sample = fread(obj.t, obj.stepRead, 'double');
                    obj.dataRaw = [obj.dataRaw ; sample];
                end
            else
                for j = 1:obj.stepRead:obj.overlapWindowSize % store only overlapWindowSize of data as the update rate (overlapping window size)
                    sample = fread(obj.t, obj.stepRead, 'double');
                    obj.dataRaw = fixWindow(obj,obj.dataRaw,sample);
                end
            end
            % obj.dataRaw{i,1}
            obj.startOverlapping = 1;
        end
        
        function detectBurst(obj)
            dataTKEO = TKEO(obj.dataRaw,obj.samplingFreq);
            [peaks,~] = triggerSpikeDetection(dataTKEO,obj.thresholds,0,obj.numStartConsecutivePoints,0);
            if ~isnan(peaks)
                obj.readyClassify = 1; % activate flag for classify
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                dataFiltered = filter(obj); % get the filtered data for each channel
                featuresTemp = featureExtraction(dataFiltered,obj.samplingFreq);
                features = featuresTemp.areaUnderCurve;
                obj.predictClass = predict(obj.classifierMdl, features);
            end
        end
    end
    
    
    
    methods(Access = protected)
        function output = setupMaxBurstLength(obj)
            output = max([obj.numStartConsecutivePoints(:); obj.numEndConsecutivePoints(:)]);
        end
        
        function dataFiltered = filter(obj)
            dataFiltered = filterData(obj.dataRaw,obj.samplingFreq,obj.highPassCutoffFreq,obj.lowPassCutoffFreq,obj.notchFreq);
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
