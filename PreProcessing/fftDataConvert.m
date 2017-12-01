function [dataFFT, fqDomain] = fftDataConvert(data, Fs)
%fftData Obtain FFT of the input data
%   [dataFFT, fqDomain] = fftData(data, Fs)


lengthData = size(data,1); % Length of data

for j = 1:size(data,2)
    P3 = fft(data(:,j));
    P2 = abs(P3 / lengthData);
    P1 = P2(1 : floor(lengthData/2+1));
    P1(2 : end-1) = 2*P1(2 : end-1);
    
    dataFFT(:,j) = P1;
end

fqDomain = Fs*(0:floor((lengthData/2)))/lengthData;

end

