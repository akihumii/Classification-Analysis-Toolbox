function [ reconstructedSignal ] = reconstructSignal( rawData, voltageStep, bitResolution, maxVoltage )
%RECONSTRUCTSIGNAL Summary of this function goes here
%This function takes in rawData either by channel or block of channels and
%convert the data to voltage form. 
%   Detailed explanation goes here
%   There are two possible ways to use this function:
%   1) Input rawData and voltage step.
%   eg. output = reconstructSignal(rawData, 0.00000095);
%   2) Input rawData, bitResolution and maxVoltage.
%   eg. output = reconstructSignal(rawData, 1024, 1.2);

% Check number of inputs.
if nargin > 3
    error('You key in too many inputs!');
end

% Fill in unset optional values.
switch nargin
    case 2
        bitResolution = 0;
        maxVoltage = 0;
    case 3
        voltageStep = 0;
end


if voltageStep == 0
    reconstructedSignal = (rawData / bitResolution) * maxVoltage;
else if bitResolution == 0 || maxVoltage == 0
        reconstructedSignal = rawData * voltageStep;
    end
end
        
end