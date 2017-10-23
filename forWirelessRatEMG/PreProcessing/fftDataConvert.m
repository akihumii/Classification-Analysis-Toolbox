function [dataFFT, fqDomain] = fftData(data, Fs, iter)
%fftData Summary of this function goes here
%   Detailed explanation goes here

L = size(data,1); % Length of data

for i = 1:iter
    P3 = fft(data(:,i));
    P2 = abs(P3 / L);
    P1 = P2(1 : L/2+1);
    P1(2 : end-1) = 2*P1(2 : end-1);
    
    dataFFT(:,i) = P1;
end

fqDomain = Fs*(0:(L/2))/L;

end

