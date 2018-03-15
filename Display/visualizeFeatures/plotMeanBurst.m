function [] = plotMeanBurst(pcaInfo,fileName,path,titleName,numChannel,plotFileName,displayInfo)
%plotMeanBurst Plot the mean burst and the evelop in analyzeFeatures.m
% 
%   [] = plotMeanBurst(pcaInfo,fileName,path,titleName,numChannel)

for i = 1:numChannel
    pMeanBursts{i,1} = plotFig(1:length(pcaInfo.burstPCAMean{i,1}),pcaInfo.burstPCAMean{i,1},fileName,['Mean of bursts and envelop (channel ',num2str(i),')'],'Time (s)','Amplitude (V)',0,1,path,'subplot');
    hold on
    plot(pMeanBursts{i,1},pcaInfo.burstPCAMeanEnvelop{i,1});
    plot(pMeanBursts{i,1},[pcaInfo.cutoffLocs(i,1),pcaInfo.cutoffLocs(i,1)],ylim);
    legend('Mean bursts','Mean bursts envelop','offset point for PCA bursts');
    
    if displayInfo.saveReconstruction % save combined figures
        savePlot(path,'Mean of bursts and envelop',plotFileName,['Mean of bursts and envelop of ',titleName,' (channel ',num2str(i),')'])
    end    
end
end

