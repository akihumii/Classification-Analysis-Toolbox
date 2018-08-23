function [] = plotFeatures(plotFeature,numChannel,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly)
%PLOTFEATURES Plot the features across the weeks in teh checkAccuracy
%fucntion
% input:    plotFeature:    Feature name (string)
% 
%   Detailed explanation goes here

for i = 1:numChannel % plot burst height across weeks
    titleName = [plotFeature,' across Weeks channel ', num2str(i)];
    saveName = [strrep(titleName,' ','_'),fileDate{1,1},'to',fileDate{end,1}];
    
    % burst height bar plot
    pBursts(i,1) = plotFig(1:iters,outputIndividual.([plotFeature,'Individual']){i,1},'',titleName,'Day','Amplitude(V)',0,1,path,'overlap',0,'barGroupedPlot');
    grid on
    hold on
    
    % errorbar
    errorbar(xCoordinates,outputIndividual.([plotFeature,'Individual']){i,1},outputIndividual.([plotFeature,'StdeIndividual']){i,1},'k.');
    
    % change the XTickLabel
    pBursts(i,1).XTick = 1:iters;
    pBursts(i,1).XTickLabel = fileDate;
    
    % insert the number of used bursts
    yLimitBursts = ylim;
    text(leftCoordinates,0.98*diff(yLimitBursts)+yLimitBursts(1),'No. for training: ');
    text(xCoordinates(:,1),repmat(0.98*diff(yLimitBursts)+yLimitBursts(1),1,iters),checkMatNAddStr(outputIndividual.numTrainBurstIndividual{i,1},',',1));
    text(leftCoordinates,0.95*diff(yLimitBursts)+yLimitBursts(1),'No. for testing: ');
    text(xCoordinates(:,1),repmat(0.95*diff(yLimitBursts)+yLimitBursts(1),1,iters),checkMatNAddStr(outputIndividual.numTestBurstIndividual{i,1},',',1));
    
    % Legend
    barObjBursts = vertcat(pBursts(i,1).Children(end-2),pBursts(i,1).Children(end-3));
    legend(barObjBursts,fileSpeedOnly,'Location','SouthEast')
end

end

