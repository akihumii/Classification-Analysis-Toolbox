classdef classOnlineClassification < matlab.System
    % For online classifiation
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    % Public, tunable properties
    properties
        predictClass = 0
        thresholds = Inf
        triggerThreshold = 0 % if it's not 0, signal will only be decoded while crossing it
        numStartConsecutivePoints
        numEndConsecutivePoints
        windowSize = 100 % ms
        windowSizeTotalPoints % in sample points
        overlapWindowSize = 50 % ms
        overlapWindowSizeTotalPoints
        blankSize = 0 %ms
        blankSizeTotalPoints % in sample points
        samplingFreq
        host
        port
        tcpipArg
        dataRaw = zeros(0,1)
        dataFiltered = zeros(0,1)
        dataFilteredHighPass = zeros(0,1)
        dataTKEO = zeros(0,1)
        highPassCutoffFreq = 30
        lowPassCutoffFreq = 450
        highPassCutoffFreqOnly = 100
        notchFreq = 50
        featureClassification;
        classifierMdl
        numClass
        threshMultStr
        predictionMethod = 'Threshold'
        t % instrument of port
        readyClassify = 0
    end
    
    properties(Nontunable)
        filterHd % handle of Parks-McClellan FIR filter
        filterHighPassHd % handle highpass FIR filter (for stimulation artefact)
    end
    
    % Pre-computed constants
    properties(Access = private)
        stepRead = 1
        dataBuffer = []
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
        function setBasicParameters(obj,data,parameters,guiInput)
            fieldNames = fieldnames(data);
            numField = length(fieldNames);
            for i = 1:numField
                obj.(fieldNames{i,1}) = data.(fieldNames{i,1}); % about the classifier
            end
            
            obj.overlapWindowSize = parameters.overlapWindowSize;
            obj.overlapWindowSizeTotalPoints = floor(obj.overlapWindowSize / 1000 * obj.samplingFreq);
            
            obj = structIntoStruct(obj, guiInput);
            
            obj.featureNames = obj.featureNamesAll(obj.featureClassification);
            obj.numFeature = length(obj.featureClassification);
            
            obj.windowSizeTotalPoints = floor(obj.windowSize / 1000 * obj.samplingFreq);
            obj.blankSizeTotalPoints = floor(obj.blankSize / 1000 * obj.samplingFreq);
            
            if or(obj.highPassCutoffFreq, obj.lowPassCutoffFreq)
                getFilterHd(obj);
                getFilterHighPassHd(obj);
            end
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
                popMsg(['Port ',num2str(obj.port),' is not open yet...'])
%                 checkFopen = fopen(obj.t);
%                 
%                 while checkFopen == -1
%                     error(['Port ',num2str(obj.port),' is not open yet...'])
%                     checkFopen = fopen(obj.t);
%                 end
                
%                 disp(['Opened port ',num2str(obj.port),' as channel port...']);
            end
        end
        
        function readSample(obj)
            if ~checkEmptyBuffer(obj)
                if ~obj.startOverlapping
                    for i = 1:obj.stepRead:obj.windowSizeTotalPoints % store windowSize of data to make it full at the first time
                        sample = fread(obj.t, obj.stepRead, 'double');
                        if checkEmptyBuffer(obj); break; end
                        obj.dataRaw = [obj.dataRaw ; sample];
                    end
                    obj.startOverlapping = 1;
                else
                    for i = 1:obj.stepRead:obj.overlapWindowSizeTotalPoints % store only overlapWindowSize of data as the update rate (overlapping window size)
                        sample = fread(obj.t, obj.stepRead, 'double');
                        obj.dataRaw = [obj.dataRaw(length(sample)+1:end); sample];
                    end

                    if or(obj.highPassCutoffFreq, obj.lowPassCutoffFreq)
                        obj.dataFiltered = filter(obj.filterHd,obj.dataRaw);
                    else
                        obj.dataFiltered = obj.dataRaw;
                    end
                    
                    if obj.port == 1345
                        plot(obj.dataFiltered);
                        ylim([-.05, .05])
                        drawnow
                    end
%                     plot(obj.filterHd.States)
                    
                    if ~isnan(obj.triggerThreshold) && length(obj.dataRaw) > 5 % if any number is input in artefactThresh
                        if any(obj.dataFiltered > obj.triggerThreshold) % if a window consists of a point that exceeds the input artefactThresh
                            while obj.t.BytesAvailable < (obj.blankSizeTotalPoints + obj.windowSizeTotalPoints)  % collect the next (blankSize + windowSize) length of data
                                drawnow
                            end
                            for i = 1:obj.t.BytesAvailable % store the data into dataRaw
                                sample = fread(obj.t, obj.stepRead, 'double');
                                if checkEmptyBuffer(obj); break; end
                                obj.dataRaw = fixWindow(obj, sample); % assure the length of dataRaw remain the same
                            end
                            obj.readyClassify = 1;
                        else
                            obj.predictClass = 0;
                        end
                    else
                        obj.readyClassify = 1;
                    end
                end
            end
        end
        
        function classifyBurst(obj)
            if obj.readyClassify
                try             
                    predictClasses(obj); % predict the classes
                catch
                    resetChannel(obj);
                end
                obj.readyClassify = 0;
            end
        end
        
    end
    
    
    methods(Access = protected)
        function extractFeatures(obj)
            featuresTemp = featureExtraction(obj.dataFiltered, obj.samplingFreq, obj.featureClassification);
            for i = 1:obj.numFeature
                obj.features(1,i) = featuresTemp.(obj.featureNames{i,1});
            end
        end
        
        function predictClasses(obj)
            switch obj.predictionMethod
                case 'Features'
                    extractFeatures(obj); % get the features
                    obj.predictClass = predict(obj.classifierMdl, obj.features);
                case 'Threshold'
                    obj.predictClass = any(obj.dataFiltered > obj.thresholds);
                otherwise
                    popMsg('Invalid predictionMethod...')
            end
            
            if obj.predictClass == obj.numClass
                obj.predictClass = 0;
            end
        end
        
        function getFilterHd(obj)
            filterObj = setFilter(classFilterDataOnline,obj.samplingFreq,obj.highPassCutoffFreq,obj.lowPassCutoffFreq,obj.notchFreq,obj.windowSizeTotalPoints); % initialize a filter object
            obj.filterHd = filterObj.Hd;
        end
        
        function getFilterHighPassHd(obj)
            filterObj = setFilter(classFilterDataOnline,obj.samplingFreq,obj.highPassCutoffFreqOnly,0,50,obj.windowSizeTotalPoints); % initialize a filter object
            obj.filterHighPassHd = filterObj.Hd;
        end
        
        function dataFiltered = filter(obj)
            dataFiltered = filter(obj.filterHd,obj.dataRaw);
        end
        
        function dataFilteredHighPass = filterHighPass(obj)
            dataFilteredHighPass = filter(obj.filterHighPassHd, obj.dataRaw);
        end
        
        function output = fixWindow(obj,sample)
            output = [obj.dataRaw(length(sample)+1 : end, 1) ; sample];
            if length(output) > obj.windowSizeTotalPoints
                output = obj.dataRaw(end-obj.windowSizeTotalPoints+1:end);
            end
        end
        
        function emptyFlag = checkEmptyBuffer(obj)
            if isempty(fread(obj.t, 1, 'double'))
                resetChannel(obj);
                disp('No data...')
                drawnow
                emptyFlag = true;
            else
                emptyFlag = false;
            end
        end
        
        function resetChannel(obj)
            popMsg('Channel reset...');
            obj.startOverlapping = 0;
            obj.dataRaw = zeros(0,1);
            obj.dataFiltered = zeros(0,1);
            obj.dataFilteredHighPass = zeros(0,1);
        end
    end
end
