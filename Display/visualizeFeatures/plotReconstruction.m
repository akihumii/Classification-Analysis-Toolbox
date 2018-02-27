function [] = plotReconstruction(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numClass)
%plotReconstruction Plot the signals before and after reconstruction by PCA
%   Detailed explanation goes here

numPlot = 4; % number of reconstructed signals to be plotted
numBursts = [zeros(1,numChannel);pcaInfo.numBursts];
samplingFreq = signalInfo(1,1).signal.samplingFreq;

for i = 1:numChannel
    arrayTemp = zeros(0,0);
    for j = 1:numClass
        arrayTemp = [arrayTemp, 1+numBursts(j,i) : (numPlot+numBursts(j,i))];
    end
    pcTemp = transpose(pcaInfo.pcaInfo(i,1).reconstructedData(arrayTemp,:));
    numPCPoints = size(pcTemp,1);
    plotFig(1/samplingFreq:1/samplingFreq:numPCPoints/samplingFreq, pcTemp, fileName, ['Reconstructed Signals Ch ',num2str(channel(i))], 'Time (s)', 'Amplitude (V)', 0, displayInfo.showPrinComp, path, 'subplot');
    
    if displayInfo.saveReconstruction
        savePlot(path,'Reconstructed Signals',plotFileName,['Reconstructed Signals Ch ',num2str(channel(i))])
    end
    if ~displayInfo.showReconstruction
        close
    end
    
end




end
