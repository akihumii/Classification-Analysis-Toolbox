function [] = plotPrinComp(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numPrinComp)
%plotPrinComp Plot principle components in visualizeFeatures
%
%   [] = plotPrinComp(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numPrinComp)


samplingFreq = signalInfo(1,1).signal.samplingFreq;

for i = 1:numChannel
    pcTemp = pcaInfo.pcaInfo(i,1).coeff(:,1:numPrinComp);
    numPCPoints = size(pcTemp,1);
    plotFig(1/samplingFreq:1/samplingFreq:numPCPoints/samplingFreq, pcTemp, fileName, ['Principle Component Coefficients Ch ',num2str(channel(i))], 'Time (s)', 'Amplitude', 0, displayInfo.showPrinComp, path, 'subplot');
    
    if displayInfo.savePrinComp
        savePlot(path,'Principle Component Coefficients',plotFileName,['Principle Component Coefficients Ch ',num2str(channel(i))])
    end
    if ~displayInfo.showPrinComp
        close
    end
    
end

end

