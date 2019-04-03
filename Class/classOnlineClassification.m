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
        signalClassifyFlag = true(0,1)
        stopClassifySize = 0
        highpassCutoffFreq = 30
        lowpassCutoffFreq = 450
        highPassCutoffFreqOnly = 100
        notchFreq = 50
        notchBandwidth = 10 % Hz
        featureClassification;
        classifierMdl
        numClass
        threshMultStr
        predictionMethod = 'Threshold'
        t % instrument of port
        readyClassify = 0
    end
    
    properties(Nontunable)
        filterObj
    end
    
    % Pre-computed constants
    properties(Access = private)
        stepRead = 1785 * 10
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
            
            obj = structIntoStruct(obj, guiInput);
            
            obj.featureNames = obj.featureNamesAll(obj.featureClassification);
            obj.numFeature = length(obj.featureClassification);

            obj.windowSizeTotalPoints = floor(obj.windowSize / 1000 * obj.samplingFreq);
            obj.blankSizeTotalPoints = floor(obj.blankSize / 1000 * obj.samplingFreq);
            obj.overlapWindowSizeTotalPoints = floor(obj.overlapWindowSize / 1000 * obj.samplingFreq);
            
            obj.filterObj = custumFilter(obj.highpassCutoffFreq, obj.lowpassCutoffFreq, obj.notchFreq, obj.notchBandwidth, obj.samplingFreq); % initialize a filter object
        end
        
        function setTcpip(obj,host,port,varargin)
            obj.host = host;
            obj.port = port;
            obj.tcpipArg = varargin;
        end
        
        function tcpip(obj)
            obj.t = tcpip(obj.host,obj.port,obj.tcpipArg{:});
            obj.t.InputBufferSize = obj.stepRead * 8;
        end
        
        function openPort(obj)
            try
                fopen(obj.t);
                disp(['Opened port ',num2str(obj.port),' as channel port...']);
            catch
                popMsg(['Port ',num2str(obj.port),' is not open yet...'])
            end
        end
        
        function readSample(obj)
            if ~checkEmptyBuffer(obj)
                if ~obj.startOverlapping
                    while length(obj.dataRaw) < obj.windowSizeTotalPoints
                        remainingSize = obj.windowSizeTotalPoints - length(obj.dataRaw);
                        if remainingSize > obj.stepRead
                            obj.dataRaw = [obj.dataRaw; fread(obj.t, obj.stepRead, 'double')];
                        else
                            obj.dataRaw = [obj.dataRaw; fread(obj.t, remainingSize, 'double')];
                        end
%                         if checkEmptyBuffer(obj); break; end
                    end             
                    obj.startOverlapping = 1;
                    
                    obj.signalClassifyFlag = true(size(obj.dataRaw));
                else
                    
                    sample = [];
                    while length(sample) < obj.overlapWindowSizeTotalPoints
                        remainingSize = obj.overlapWindowSizeTotalPoints - length(sample);
                        if remainingSize > obj.stepRead
                            sample = [sample; fread(obj.t, obj.stepRead, 'double')];
                        else
                            sample = [sample; fread(obj.t, remainingSize, 'double')];
                        end
%                         if checkEmptyBuffer(obj); break; end
                    end                    

                    sampleSize = length(sample);
                    obj.dataRaw = [obj.dataRaw(sampleSize+1:end); sample];
                    
                    dataSize = length(obj.dataRaw);
                    
                    obj.signalClassifyFlag = [obj.signalClassifyFlag(sampleSize+1:end); true(sampleSize,1)];
                    if dataSize > obj.stopClassifySize
                        obj.signalClassifyFlag(1:obj.stopClassifySize) = false;
                        obj.stopClassifySize = 0;
                    else
                        obj.signalClassifyFlag(:) = false;
                        obj.stopClassifySize = obj.stopClassifySize - dataSize;
                    end
                    
                    obj.dataFiltered = filter(obj);
                    
%                     if obj.port == 1345
%                         disp(max(obj.dataRaw));
%                         plot(obj.dataRaw);
%                         plot(obj.dataFiltered);
%                         ylim([-.5, .5])
%                         drawnow
%                     end

                    if ~obj.stopClassifySize
                        locArtefact = find(obj.dataFiltered > obj.triggerThreshold, 1, 'first');
                        if ~isempty(locArtefact)
                            if (dataSize - locArtefact) > obj.blankSizeTotalPoints
                                obj.signalClassifyFlag(locArtefact : locArtefact+obj.blankSizeTotalPoints) = false;
                                obj.stopClassifySize = 0;
                            else
                                obj.signalClassifyFlag(locArtefact : end) = false;
                                obj.stopClassifySize = obj.blankSizeTotalPoints - (dataSize - locArtefact);
                            end
                        end
                    end
                end
            end
        end
        
        function classifyBurst(obj)
            try
                predictClasses(obj); % predict the classes
            catch
                resetChannel(obj);
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
                    if isobject(obj.classifierMdl)
                        extractFeatures(obj); % get the features
                        obj.predictClass = predict(obj.classifierMdl, obj.features);
                    end
                case 'Threshold'
                    if ~isempty(obj.dataFiltered)
                        obj.predictClass = any(obj.dataFiltered(obj.signalClassifyFlag) > obj.thresholds);
                    else
                        disp('Empty dataFiltered...')
                    end
                otherwise
                    popMsg('Invalid predictionMethod...')
            end
            
            if obj.predictClass == obj.numClass
                obj.predictClass = 0;
            end
        end
        
        function dataFiltered = filter(obj)
            dataFiltered = filterData(obj.filterObj, obj.dataRaw, 1);
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
