function [] = visualizeFeatures(iter, path, channel, featureStde, titleName, fileName, fileSpeed, fileDate, numChannel, featureMean, featuresNames, numFeatures, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures)
%visualizeFeatures Visualize the features
%   Detailed explanation goes here

if showFigures==1 || saveFigures==1 || showSeparatedFigures==1 || saveSeparatedFigures==1
    switch titleName
        case 'Different Speed'
            plotFileName = [fileName{1,1}(1:6),fileName{1,1}(12:17)];
            xScale = 'Speed(cm/s)';
            xTickValue = fileSpeed;
        case 'Different Day';
            plotFileName = fileName{1,1}(1:8);
            xScale = 'Date';
            xTickValue = fileDate;
        case 'Active EMG'
            plotFileName = fileName{1,1};
            xScale = '';
            xTickValue = [{'non-activated EMG'};{'activated EMG'}];
    end
    
    for i = 1:numFeatures
        for j = 1:numChannel
            [p(i,j),f(i,j)] = plotFig(1:iter,transpose(featureMean(i,:,j)),plotFileName,featuresNames{i,1},xScale,'',...
                0,... % save
                1,... % show
                path, 'subPlot',channel(1,j),'barPlot');
            p(i,j).XTick = 1:iter;
            p(i,j).XTickLabel = xTickValue;
            hold on
            errorbar(1:iter,transpose(featureMean(i,:,j)),featureStde(i,:,j),'r*');
            
            if saveSeparatedFigures
                savePlot(path,['Features sorted in ',titleName,],plotFileName,[featuresNames{i,1},' with ',titleName,' of ch ',num2str(channel(1,j)),' in ',plotFileName])
            end
            
        end
    end
    
    %% Plot all the features
    for i = 1:numChannel
        [~,fS(i,1)] = plots2subplots(p(:,i),2,4);
        if saveFigures
            savePlot(path,['Features sorted in ',titleName,],plotFileName,['All the Features with ',titleName,' of ch ',num2str(channel(1,i)),' in ',plotFileName])
        end
    end
    
    if ~showSeparatedFigures
        delete(f)
    end
    
    if ~showFigures
        delete(fS(:,1))
    end
end


end

