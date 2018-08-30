function p = plotFeatures(plotFeature,plotType,numChannel,fileSpeed,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly,dataTemp,titleType)
%PLOTFEATURES Plot the features across the weeks in teh checkAccuracy
%fucntion
% input:    plotFeature:    Feature name (string)
%           plotType:       medianPlot,meanPlot
%           titleType:      type for increment numbers shown in figures
%
%   [] = plotFeatures(plotFeature,plotType,numChannel,fileDate,outputIndividual,xCoordinates,iters,leftCoordinates,fileSpeedOnly)

for i = 1:numChannel % plot burst height across weeks
    titleName = [plotFeature,' across Weeks ',titleType,' ',num2str(i)];
    saveName = [strrep(titleName,' ','_'),fileDate{1,1},'to',fileDate{end,1}];
    
    % burst height bar plot
    
    switch plotType
        case 'meanPlot'
            p(i,1) = plotFig(1:iters,outputIndividual.([plotFeature,'Individual']){i,1},'',titleName,'Day','Amplitude(V)',0,1,path,'overlap',0,'barGroupedPlot');
            grid on
            hold on
            
            % errorbar
            errorbar(xCoordinates,outputIndividual.([plotFeature,'Individual']){i,1},outputIndividual.([plotFeature,'StdeIndividual']){i,1},'k.');
            
            % Legend
            barObjBursts = vertcat(p(i,1).Children(end-2),p(i,1).Children(end-3));
            legend(barObjBursts,fileSpeedOnly,'Location','SouthEast')
            
        case 'medianPlot'
            p(i,1) = plotFig(1:iters,outputIndividual.([plotFeature,'MedianIndividual']){i,1},'',titleName, '', 'Accuracy', 0, 1, path, 'overlap', 0, 'barGroupedPlot');
            ylim([0,1]);
            hold on
            
            % plot the mean
            meanTemp = outputIndividual.([plotFeature,'AveIndividual']){i,1};
            plot(xCoordinates,meanTemp,'r*');
            
            % plot the percentile
            medianTemp = outputIndividual.([plotFeature,'MedianIndividual']){i,1};
            perc5Temp = medianTemp(:) - outputIndividual.([plotFeature,'Perc5Individual']){i,1}(:);
            perc95Temp = outputIndividual.([plotFeature,'Perc95Individual']){i,1}(:) - medianTemp(:);
            errorbar(xCoordinates(:),medianTemp(:),perc5Temp,perc95Temp,'kv');
            
            % insert speed
            text(xCoordinates(:,1),repmat(0.05,1,iters),fileSpeed);
            
            % insert date
            text(xCoordinates(:,1),repmat(-0.07,1,iters),fileDate);
            
            % insert faeture legend
            legendMat = horzcat(mat2cell(transpose(1:8),ones(8,1),1),dataTemp.varargin{1,2}.featuresNames);
            legendText = checkMatNAddStr(legendMat,': ',1);
            t = text(leftCoordinates,0.1,legendText);
            
            % input bar legend
            barObj = vertcat(p(i,1).Children(end-2),p(i,1).Children(end-3),p(i,1).Children(end-4),p(i,1).Children(end-6));
            barObjLegend = [{'1-feature classification'};{'2-feature classification'};{'Mean value'};{'5 to 95 percentile'}];
            legend(barObj,barObjLegend,'Location','SouthEast')
            grid on
            
            
        otherwise
            warning(['Invalid plot type of ',plotType,'...'])
            break
    end
    
    % change the XTickLabel
    p(i,1).XTick = 1:iters;
    p(i,1).XTickLabel = fileDate;
    
    
    % insert the number of used bursts
    yLimitBursts = ylim;
    text(leftCoordinates,0.98*diff(yLimitBursts)+yLimitBursts(1),'No. for training: ');
    text(xCoordinates(:,1),repmat(0.98*diff(yLimitBursts)+yLimitBursts(1),1,iters),checkMatNAddStr(outputIndividual.numTrainBurstIndividual{i,1},',',1));
    text(leftCoordinates,0.95*diff(yLimitBursts)+yLimitBursts(1),'No. for testing: ');
    text(xCoordinates(:,1),repmat(0.95*diff(yLimitBursts)+yLimitBursts(1),1,iters),checkMatNAddStr(outputIndividual.numTestBurstIndividual{i,1},',',1));
    
end

end
