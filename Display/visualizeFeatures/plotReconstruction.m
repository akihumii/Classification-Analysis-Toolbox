function [] = plotReconstruction(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numClass)
%plotReconstruction Plot the signals before and after reconstruction by PCA
%   [] = plotReconstruction(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numClass)

numPlot = 4; % number of reconstructed signals to be plotted
numBursts = [zeros(1,numChannel);pcaInfo.numBursts];
samplingFreq = signalInfo(1,1).signal.samplingFreq;

for i = 1:numChannel
    arrayTemp = zeros(0,0);
    for j = 1:numClass
        arrayTemp = 1+numBursts(j,i) : (numPlot+numBursts(j,i));
        for k = 1:numPlot
            pcTemp = horzcat(transpose(pcaInfo.pcaInfo(i,1).reconstructedData(arrayTemp(1,k),:)),... % reconstructed burst
                transpose(pcaInfo.pcaInfo(i,1).rawData(arrayTemp(1,k),:))); % raw burst
            numPCPoints = size(pcTemp,1);
            [pReconstructedSignal{k,j},fReconstructedSignal(k,j)] = plotFig(1/samplingFreq:1/samplingFreq:numPCPoints/samplingFreq, pcTemp, fileName, ['Reconstructed Signals Ch ',num2str(channel(i)),' Class ',num2str(j)], 'Time (s)', 'Amplitude (V)', 0, displayInfo.showReconstruction, path, 'overlap');
        end
    end
    
    plots2subplots(vertcat(pReconstructedSignal{:,:}),numPlot,2);
    legend('Reconstructed burst','Raw burst')
    delete(fReconstructedSignal);
    
    if displayInfo.saveReconstruction
        savePlot(path,'Reconstructed Signals',plotFileName,['Reconstructed Signals Ch ',num2str(channel(i))])
    end
    if ~displayInfo.showReconstruction
        close
    end
    
end




end
