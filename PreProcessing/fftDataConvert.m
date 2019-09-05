function [dataFFT, fqDomain] = fftDataConvert(data, Fs)
%fftData Obtain FFT of the input data
%   [dataFFT, fqDomain] = fftData(data, Fs)


lengthData = size(data,1); % Length of data

for n = 1:size(data,3)
    for j = 1:size(data,2)
        %     P3 = fft(data(:,j));
        %     P2 = abs(P3 / lengthData);
        %     P1 = P2(1 : floor(lengthData/2+1));
        %     P1(2 : end-1) = 2*P1(2 : end-1);
        
        P2 = fft(data(:,j));
        P1 = abs(P2);
        dataFFT(:,j,n) = P1;
    end
end
dF = Fs/lengthData;
fqDomain = 0 : dF : Fs-dF;
% fqDomain = Fs*(0:floor((lengthData/2)))/lengthData;

end

