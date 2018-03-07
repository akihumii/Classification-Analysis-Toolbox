function [] = plotFeatures(numFeatures,numChannel,iter,featuresInfo,plotFileName,xScale,path,channel,xTickValue,displayInfo,titleName,numRowSubplots)
%plotFeatures Plot features in visualizeFeatures
%   [] = plotFeatures(numFeatures,numChannel,iter,featuresInfo,plotFileName,xScale,path,channel,xTickValue,displayInfo,titleName,numRowSubplots)

for i = 1:numFeatures
    for j = 1:numChannel
        [p(i,j),f(i,j)] = plotFig(1:iter,transpose(featuresInfo.featureMean(i,:,j)),plotFileName,featuresInfo.featuresNames{i,1},xScale,'',0,1,path, 'subPlot',channel(1,j),'barPlot');
        p(i,j).XTick = 1:iter;
        p(i,j).XTickLabel = xTickValue;
        hold on
        errorbar(1:iter,transpose(featuresInfo.featureMean(i,:,j)),featuresInfo.featureStde(i,:,j),'r*');
        
        if displayInfo.saveSeparatedFigures
            savePlot(path,['Features sorted in ',titleName,],plotFileName,[featuresInfo.featuresNames{i,1},' with ',titleName,' of ch ',num2str(channel(1,j)),' in ',plotFileName, ' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        
    end
end

%% Plot all the features
for i = 1:numChannel
    [~,fS(i,1)] = plots2subplots(p(:,i),numRowSubplots,numFeatures/numRowSubplots);
    if displayInfo.saveFigures
        savePlot(path,['Features sorted in ',titleName,],plotFileName,['All the Features with ',titleName,' of ch ',num2str(channel(1,i)),' in ',plotFileName,' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
    end
end
if ~displayInfo.showSeparatedFigures
    delete(f)
end
if ~displayInfo.showFigures
    delete(fS(:,1))
end




end

