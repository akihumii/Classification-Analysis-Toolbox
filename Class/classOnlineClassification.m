classdef classOnlineClassification < matlab.System
    % Untitled3 Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        threshold
        numOnsetBurst
        numOffsetBurst
        maxBurstLength
        samplingFreq
        lengthTKEO = 13;
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods
        function setOnlineClassifier(obj,data)
            obj.threshold = data{1,1};
            obj.numOnsetBurst = data{1,2};
            obj.numOffsetBurst = data{1,3};
            obj.samplingFreq = data{1,4};
            obj.maxBurstLength = setupMaxBurstLength(obj);
        end
    end
    
    methods(Access = protected)
        
        function output = setupMaxBurstLength(obj)
            output = max([obj.numOnsetBurst(:); obj.numOffsetBurst(:)]);
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            y = u;
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end
    end
end
