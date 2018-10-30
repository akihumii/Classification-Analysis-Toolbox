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
        dataFiltered = zeros(0,1)
        dataTKEO = zeros(0,1)
        highPassCutoffFreq = 30
        lowPassCutoffFreq = 450
        notchFreq = 50
        featureClassification;
        classifierMdl
        numClass
    end
    
    properties(Nontunable)
        filterHd % handle of Parks-McClellan FIR filter
        readyClassify = 1
    end
    
    % Pre-computed constants
    properties(Access = private)
        t % instrument of port
        stepRead % number of sample to read and store per time
        startOverlapping = 0 % flag to indicte that the window is full and ready to start overlapping
        features = zeros(1,0)
        featureNames
        numFeature
        featureNamesAll = {...
            'maxValue';...
            'minValue';...
            'burstLength';...
            'areaUnderCurve';...
            'meanValue';...
            'sumDifferences';...
            'numZeroCrossings';...
            'numSignChanges'};
    end
    
    methods
        function setBasicParameters(obj,data,parameters)
            fieldNames = fieldnames(data);
            numField = length(fieldNames);
            for i = 1:numField
                obj.(fieldNames{i,1}) = data.(fieldNames{i,1}); % about the classifier
            end
            
            obj.overlapWindowSize = parameters.overlapWindowSize;
            
            updateStepRead(obj); % update the step size to store the data from Qt
            
            obj.featureNames = obj.featureNamesAll(obj.featureClassification);
            obj.numFeature = length(obj.featureClassification);
            
            obj = getFilterHd(obj);
        end
        
        function setTcpip(obj,host,port,varargin)
            obj.host = host;
            obj.port = port;
            obj.tcpipArg = varargin;
        end
                
        function tcpip(obj)
            obj.t = tcpip(obj.host,obj.port,obj.tcpipArg{:});
        end
        
        function openPort(obj)
            try
                fopen(obj.t);
                disp(['Opened port ',num2str(obj.port),' as channel port...']);
            catch
                error(['Port ',num2str(obj.port),' is not open yet...'])
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
            obj.startOverlapping = 1;
        end
        
        function detectBurst(obj)
            if ~obj.readyClassify
                obj.dataTKEO = TKEO(obj.dataRaw,obj.samplingFreq);
                [peaks,~] = triggerSpikeDetection(obj.dataTKEO,obj.thresholds,0,obj.numStartConsecutivePoints,0);
                if ~isnan(peaks)
                    obj.readyClassify = 1; % activate flag for classify
                end
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                obj.dataFiltered = filter(obj); % get the filtered data for each channel
                featuresTemp = featureExtraction(obj.dataFiltered, obj.samplingFreq, obj.featureClassification);
                for i = 1:obj.numFeature
                    obj.features(1,i) = featuresTemp.(obj.featureNames{i,1});
                end
                obj.predictClass = predict(obj.classifierMdl, obj.features);
                if obj.predictClass == obj.numClass
                    obj.predictClass = 0;
                end
            end
        end
        
    end
    
    
    
    methods(Access = protected)
        function obj = getFilterHd(obj)
            filterObj = setFilter(classFilterDataOnline,obj.samplingFreq,obj.highPassCutoffFreq,obj.lowPassCutoffFreq,obj.notchFreq,obj.windowSize); % initialize a filter object
            obj.filterHd = filterObj.Hd;
        end

        
        function dataFiltered = filter(obj)
            dataFiltered = filter(obj.filterHd,obj.dataRaw);
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
