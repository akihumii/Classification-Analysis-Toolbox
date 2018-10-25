classdef classFilterDataOnline < matlab.System
    % filterDataOnline Do the online filtering with dfilt.fftfir and firpm
    
    % Public, tunable properties
    properties
        dataFiltered
        samplingFreq
        highPassCutoffFreq
        lowPassCutoffFreq
        notchFreq
        windowSize
        lowPassFilterEnabled = 0
        highPassFilterEnabled = 0
        bandPassFilterEnabled = 0
        notchFilterEnabled = 0
    end

    properties(Nontunable)
        Wpass = 1;
        Wstop = 100;
        order = 50;
        targetArray
        freqArray
        weightArray
    end

    % Pre-computed constants
    properties(Access = private)
        Hd
    end

    methods
        function filterDataOnline(obj,dataRaw,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize)
            obj = insertParameters(obj,samplingFreq,highPassCutoffFreq,lowPassCutoffFreq,notchFreq,windowSize);
            obj = checkSelectedFilter(obj,highPassCutoffFreq,lowPassCutoffFreq,notchFreq);
            obj = setFilterCoeff(obj);
            obj = getFilterHd(obj);
            obj.dataFiltered = filter(obj.Hd,dataRaw);
        end
    end
    
    
    methods(Access = protected)
        function obj = insertParameters(obj,varargin)
            for i = 1:nargin-1
                obj.(inputname(i+1)) = varargin{1,i};
            end
        end
        
        function obj = checkSelectedFilter(obj,highPassCutoffFreq,lowPassCutoffFreq,notchFreq)
            obj.bandPassFilterEnabled = lowPassCutoffFreq && highPassCutoffFreq;
            obj.lowPassFilterEnabled = lowPassCutoffFreq && ~obj.bandPassFilterEnabled;
            obj.highPassFilterEnabled = highPassCutoffFreq && ~obj.bandPassFilterEnabled;
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
                obj.freqArray = [0,Fstop1,obj.lowCutoffFreq,obj.samplingFreq/2] / (obj.samplingFreq/2);
                obj.weightArray = [obj.Wstop,obj.Wpass];
                
            elseif obj.lowPassFilterEnabled
                obj.targetArray = [1,1,0,0];
                obj.freqArray = [0,obj.highCutoffFreq,Fstop2,obj.samplingFreq/2] / (obj.samplingFreq/2);
                obj.weightArray = [obj.Wpass, obj.Wstop];
            end

        end

        function [Fstop,i] = getFstop1(obj)
            for i = 50:-5:0
                Fstop = obj.highPassCutoffFreq - i;
                if Fstop > 0
                    break
                end
            end
            if Fstop < 0
                Fstop = 0;
            end
        end
        
        function obj = getFilterHd(obj)
            b = firpm(obj.order,obj.freqArray,obj.targetArray,obj.weightArray);
            obj.Hd = dfilt.fftfir(b,obj.windowSize);
            obj.Hd.PersistentMemory = true;
        end
        
    end
end
