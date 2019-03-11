classdef custumFilter < matlab.System

    properties
        notchFilterEnabled = false;
        lowpassFilterEnabled = false;
        highpassFilterEnabled = false;
        highpassCutoffFreq = 100;
        lowpassCutoffFreq = 0;
        notchFreq = 0;
        notchBandwidth = 10;
        samplingFreq;
    end
    
    properties(Access = private)
        a0_hp; a1_hp; a2_hp; b1_hp; b2_hp;        % coefficients for 2nd order low pass butterworth filter
        a0_lp; a1_lp; a2_lp; b1_lp; b2_lp;        % coefficients for 2nd order high pass butterworth filter
        a0_n; a1_n; a2_n; b1_n; b2_n;             % coefficients for notch filter
        TWO_PI = 6.28318530718;
        filteredData = cell(2,1)
        filteredData_hp = cell(1,1);
        filteredData_n = cell(1,1);
        prevRawData = cell(1,1);
    end

    methods
        function obj = custumFilter(highpassCutoffFreq, lowpassCutoffFreq, notchFreq, notchBandwidth, samplingFreq)
            obj.highpassCutoffFreq = highpassCutoffFreq;
            obj.lowpassCutoffFreq = lowpassCutoffFreq;
            obj.notchFreq = notchFreq;
            obj.samplingFreq = samplingFreq;
            obj.notchBandwidth = notchBandwidth;
        end
        
        function setLowpassFilter(obj)
            % Set cutoff frequency and sample frequency for calculation of butterworth low pass filter's coefficient
            obj.lowpassCutoffFreq = obj.lowpassCutoffFreq;
            fr = obj.samplingFreq/obj.lowpassCutoffFreq;
            omega = tan(pi/fr);
            c = 1 + cos(pi/4) * omega + (omega * omega);
            obj.a0_lp = (omega * omega) / c;
            obj.a2_lp = obj.a0_lp;
            obj.a1_lp = obj.a0_lp * 2;
            obj.b1_lp = 2 * (omega * omega - 1) / c;
            obj.b2_lp = (1 - cos(pi/4) * omega + (omega * omega)) / c;
        end

        function setNotchFilter(obj)
            % Set notch filter parameters.  All filter parameters are given in Hz (or
            % in Samples/s).  A bandwidth of 10 Hz is recommended for 50 or 60 Hz notch
            % filters.  Narrower bandwidths will produce extended ringing in the time
            % domain in response to large transients.
            obj.notchFreq = obj.notchFreq;
            d = exp(-pi * obj.notchBandwidth / obj.samplingFreq);

            % Calculate biquad IIR filter coefficients.
            obj.b1_n = -(1.0 + d * d) * cos(2.0 * pi * obj.notchFreq / obj.samplingFreq);
            obj.b2_n = d * d;
            obj.a0_n = (1 + d * d) / 2.0;
            obj.a1_n = obj.b1_n;
            obj.a2_n = obj.a0_n;
        end

        function setHighpassFilter(obj)
            % Set cutoff frequency and sample frequency for calculation of butterworth high pass filter's coefficient
            obj.highpassCutoffFreq = obj.highpassCutoffFreq;
            obj.highpassCutoffFreq = 0.5*obj.samplingFreq - obj.highpassCutoffFreq;
            fr = obj.samplingFreq/obj.highpassCutoffFreq;
            omega = tan(pi/fr);
            c = 1 + cos(pi/4) * omega + (omega * omega);
            obj.a0_hp = (omega * omega) / c;
            obj.a2_hp = obj.a0_hp;
            obj.a1_hp = obj.a0_hp * -2;
            obj.b1_hp = -2 * (omega * omega - 1) / c;
            obj.b2_hp = (1 - cos(pi/4) * omega + (omega * omega)) / c;
        end

        function rawData = filterData(obj, rawData, ChannelIndex)
            if(length(obj.prevRawData{ChannelIndex}) >= 2)
                rawData = [obj.prevRawData{ChannelIndex}(end-1:end); rawData];
            end
            
            obj.prevRawData{ChannelIndex} = rawData(end-1:end);
            
            if(obj.notchFilterEnabled)
                rawData = notchFilter(obj, rawData, ChannelIndex);
            end
            if(obj.highpassFilterEnabled)
                rawData = hipassFilter(obj, rawData, ChannelIndex);
            end
            if(obj.lowpassFilterEnabled)
                rawData = lopassFilter(obj, rawData, ChannelIndex);
            end
        end

        function output = hipassFilter(obj, rawData, ChannelIndex)
            if(length(obj.filteredData_hp{ChannelIndex}) > 1)
                obj.filteredData_hp{ChannelIndex}(1:end-2) = [];
            else
                obj.filteredData_hp{ChannelIndex} = [obj.filteredData_hp{ChannelIndex}; rawData(1:2)];
            end
            
            for t = 3:length(rawData)
                temp = obj.a0_hp * rawData(t) + obj.a1_hp * rawData(t-1) + obj.a2_hp * rawData(t-2) - obj.b1_hp * obj.filteredData_hp{ChannelIndex}(t-1) - obj.b2_hp * obj.filteredData_hp{ChannelIndex}(t-2);
                obj.filteredData_hp{ChannelIndex} = [obj.filteredData_hp{ChannelIndex}; temp];
            end        
            output = obj.filteredData_hp{ChannelIndex};
        end

        function output = lopassFilter(obj, rawData, ChannelIndex)
            if(length(obj.filteredData{ChannelIndex}) > 1)
                obj.filteredData{ChannelIndex}(1:end-2) = [];
            else
                obj.filteredData{ChannelIndex} = [obj.filteredData{ChannelIndex}; rawData(1:2)];
            end
            
            for t = 3:length(rawData)
                temp = obj.a0_lp * rawData(t) + obj.a1_lp * rawData(t-1) + obj.a2_lp * rawData(t-2) - obj.b1_lp * obj.filteredData{ChannelIndex}(t-1) - obj.b2_lp * obj.filteredData{ChannelIndex}(t-2);
                obj.filteredData{ChannelIndex} = [obj.filteredData{ChannelIndex}; temp];
            end
            
            output = obj.filteredData{ChannelIndex};
        end

        function output = notchFilter(obj, rawData, ChannelIndex)
            if(length(obj.filteredData_n{ChannelIndex}) > 1)
                obj.filteredData_n{ChannelIndex}(1:end-2) = [];
            else
                obj.filteredData_n{ChannelIndex} = [obj.filteredData_n{ChannelIndex}; rawData(1:2)];
            end
            
            for t = 3:length(rawData)
                temp = obj.a0_n * rawData(t) + obj.a1_n * rawData(t-1) + obj.a2_n * rawData(t-2) - obj.b1_n * obj.filteredData_n{ChannelIndex}(t-1) - obj.b2_n * obj.filteredData_n{ChannelIndex}(t-2);
                obj.filteredData_n{ChannelIndex} = [obj.filteredData_n{ChannelIndex}; temp];
            end
            
            output = obj.filteredData_n{ChannelIndex};
        end

%         function setLowpassFilterEnabled(obj, enableFlag)
%             obj.lowpassFilterEnabled = enableFlag;
%         end
% 
%         function setNotchFilterEnabled(obj, enableFlag)
%             obj.notchFilterEnabled = enableFlag;
%         end
% 
%         function setHighpassFilterEnabled(obj, enableFlag)
%             obj.highpassFilterEnabled = enableFlag;
%         end
% 
%         function output = isHighpassFilterEnabled(obj)
%             output = obj.highpassFilterEnabled;
%         end
% 
%         function output = isLowpassFilterEnabled(obj)
%             output = obj.lowpassFilterEnabled;
%         end
% 
%         function output = isNotchFilterEnabled(obj)
%             output = obj.notchFilterEnabled;
%         end
% 
        function output = isFilterEnabled(obj)
            output = obj.highpassFilterEnabled || obj.lowpassFilterEnabled || obj.notchFilterEnabled;
        end

%         function output = currentLowpassFreq(obj)
%             output = obj.lowpassCutoffFreq;
%         end
% 
%         function output = currentHighpassFreq(obj)
%             output = obj.highpassCutoffFreq;
%         end
% 
%         function output = currentNotchFreq(obj)
%             output = obj.notchFreq;
%         end
% 
%         function setSamplingFreq(obj, freq)
%             obj.samplingFreq = freq;
%         end
% 
%         function output = getSamplingFreq(obj)
%             output = obj.samplingFreq;
%         end

        function output = getPeriod(obj)
            output = 1.0/obj.samplingFreq;
        end
    end
end