classdef classFilterDataOnline < matlab.System
    % filterDataOnline Do the online filtering with dfilt.fftfir and firpm
    
    % Public, tunable properties
    properties
        samplingFreq
        highPassCutoffFreq
        lowPassCutoffFreq
        notchFreq
        windowSize
        PersistentMemoryFlag = true
        lowPassFilterEnabled = 0
        highPassFilterEnabled = 0
        bandPassFilterEnabled = 0
        notchFilterEnabled = 0
    end

    properties(Nontunable)
        Hd
        butterCoeff
        Wpass = 1;
        Wstop = 100;
        order = 50;
        targetArray
        freqArray
        weightArray
    end

    % Pre-computed constants
    properties(Access = private)
    end

    methods
        function dataFiltered = filterDataOnline(obj,dataRaw,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize)
            obj = setFilter(obj,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize);
            dataFiltered = filter(obj.Hd,dataRaw);
        end
        
        function obj = setFilter(obj,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize)
            % function obj = setFilter(obj,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize)
            
            obj = insertParameters(obj,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize);
            obj = checkSelectedFilter(obj,highPassCutoffFreq,lowPassCutoffFreq,notchFreq);
            obj = setFilterCoeff(obj);
            obj = getFilterHd(obj);
        end
    end
    
    
    methods(Access = protected)
        
        function obj = getFilterHd(obj)
            b = firpm(obj.order,obj.freqArray,obj.targetArray,obj.weightArray);
            obj.Hd = dfilt.fftfir(b,obj.windowSize);
            obj.Hd.PersistentMemory = obj.PersistentMemoryFlag;
        end
        
        function obj = insertParameters(obj,varargin)
            for i = 1:nargin-1
                obj.(inputname(i+1)) = varargin{1,i};
            end
            
            if obj.windowSize == 0
                obj.windowSize = 100; % default value for dfilt.fftfir
            end
        end
        
        function obj = checkSelectedFilter(obj,highPassCutoffFreq,lowPassCutoffFreq,notchFreq)
            obj.bandPassFilterEnabled = lowPassCutoffFreq && highPassCutoffFreq;
            obj.lowPassFilterEnabled = lowPassCutoffFreq && ~highPassCutoffFreq;
            obj.highPassFilterEnabled = highPassCutoffFreq && ~lowPassCutoffFreq ;
%             obj.lowPassFilterEnabled = lowPassCutoffFreq && ~obj.bandPassFilterEnabled;
%             obj.highPassFilterEnabled = highPassCutoffFreq && ~obj.bandPassFilterEnabled;
            obj.notchFilterEnabled = notchFreq == 1;
        end

        function obj = setFilterCoeff(obj)
            [Fstop1,stopFreqStep] = getFstop1(obj);
            Fstop2 = obj.lowPassCutoffFreq + stopFreqStep;
            if Fstop2 > obj.samplingFreq/2
                Fstop2 = obj.samplingFreq/2;
            end

            if obj.bandPassFilterEnabled
                obj.targetArray = [0,0,1,1,0,0];
                obj.freqArray = [0,Fstop1,obj.highPassCutoffFreq,obj.lowPassCutoffFreq,Fstop2,obj.samplingFreq/2] / (obj.samplingFreq/2);
                obj.weightArray = [obj.Wstop, obj.Wpass, obj.Wstop];
                
            elseif obj.highPassFilterEnabled
                obj.targetArray = [0,0,1,1];
                obj.freqArray = [0,Fstop1,obj.highPassCutoffFreq,obj.samplingFreq/2] / (obj.samplingFreq/2);
                obj.weightArray = [obj.Wstop,obj.Wpass];
                
            elseif obj.lowPassFilterEnabled
                obj.targetArray = [1,1,0,0];
                obj.freqArray = [0,obj.lowPassCutoffFreq,Fstop2,obj.samplingFreq/2] / (obj.samplingFreq/2);
                obj.weightArray = [obj.Wpass, obj.Wstop];
            end

        end

        function [Fstop,i] = getFstop1(obj)
            for i = 50:-1:0
                Fstop = obj.highPassCutoffFreq - i;
                if Fstop > 0
                    break
                end
            end
            if Fstop < 0
                Fstop = 0;
            end
        end
        
    end
end
