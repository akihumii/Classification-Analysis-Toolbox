function [] = reviewAnalysingWindows(data,spikeLocs,fileName,path,Fs)
%reviewAnalysingWindows plot the overlapping windows
%   [] = reviewAnalysingWindows()

numFile = length(spikeLocs);
numChannel = length(spikeLocs{1,1});

windowBeforeSpike = floor(0.001 * Fs);
windowAfterSpike = floor(0.04 * Fs);

for i = 1:numFile
    for j = 1:numChannel
        numSpikes = length(spikeLocs{i,1}{j,1}(1:10));
        windowsSelected = zeros(0,0);
        for k = 1:10
            windowsSelected(:,k) = ...
                data{i,1}(spikeLocs{i,1}{j,1}(k,1) - windowBeforeSpike:...
                spikeLocs{i,1}{j,1}(k,1) + windowAfterSpike,j);
        end
        
        plotFig(-windowBeforeSpike/Fs:1/Fs:windowAfterSpike/Fs,windowsSelected,...
            fileName{i},[' Overlapped Windows Ch ',num2str(j)],...
            'Time(s)','Amplitude(V)','y','n',path, 'y');
    end
end


