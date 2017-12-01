function [ signalFFT ] = computeBandwidth( signal, samplingFreq )
%   COMPUTEBANDWIDTH Summary of this function goes here
%   Taking reference from this: https://www.mathworks.com/help/matlab/ref/fft.html
%   Detailed explanation goes here
%   Fs = samplingFreq;
%   T = period;
%   L = length;
%   t = t;
%   X = signal;
%   Y = temp1;
%   P1 = temp2;
%   P2 = signalFFT.yValue
%   f = signalFFT.xValue

length = size(signal, 1);

temp1 = fft(signal);
temp2 = abs(temp1/length);

signalFFT.yValue = transpose(temp2(1:floor(length/2)+1));
signalFFT.yValue(1:2) = 0;
signalFFT.yValue(2:end-1) = 2*signalFFT.yValue(2:end-1);
signalFFT.yValue = mag2db(signalFFT.yValue);
signalFFT.xValue = samplingFreq*(0:(length/2))/length;

end