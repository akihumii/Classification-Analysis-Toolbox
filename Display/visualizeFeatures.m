function [] = visualizeFeatures(iter, path, channel, featureIndex, accuracyBasicParameter, featuresAll, featureStde, titleName, fileName, fileSpeed, fileDate, featureMean, featuresNames, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures, saveHistFit, showHistFit, saveAccuracy, showAccuracy)
%visualizeFeatures Visualize the features
%   Detailed explanation goes here

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

[numClass, numFeatures, numChannel] = size(featuresAll); % the sizes of the features properties
numFeatureCombination = length(accuracyBasicParameter);
colorArray = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840];

if showFigures || saveFigures || showSeparatedFigures || saveSeperatedFigures
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

%% Plot Accuracy
if showAccuracy || saveAccuracy
    for i = 1:numFeatureCombination
        numCombination = length(accuracyBasicParameter{i,1}); % number of combination
        featureIndexTemp = featureIndex{i,1};
        meanTemp = vertcat(accuracyBasicParameter{i,1}.mean);
        stdeTemp = vertcat(accuracyBasicParameter{i,1}.stde);
        [pA,~,lA] = plotFig(1:numCombination,meanTemp,plotFileName,['Accuracy with ',num2str(i),' features in combinations'],'Feature Combinations','Amplitude',...
            0,... % save
            1,... % show
            path,'overlap',0,'barStackedPlot');
        hold on
        legend(xTickValue);
        pA.XTick = featureIndexTemp;
        errorbar(getErrorBarXAxisValues(8,2),meanTemp,stdeTemp,'r*');
        if saveAccuracy
            savePlot(path,'Accuracy of Features Combination',plotFileName,['Accuracy with ',num2str(i),' features in combinations'])
        end
        if ~showAccuracy
            close
        end
    end
end
%% Plot histogram and distribution (for single features in all classes)
if showHistFit || saveHistFit
    for i = 1:numChannel
        for j = 1:numFeatures
            featuresTemp = cell2nanMat(featuresAll(:,j,i)); % reconstruct the same features from all classes into a matrix
            [pHist(j,i),fHist(j,i),hHist] = plotFig(0,featuresTemp,plotFileName,['Distribution of ',featuresNames{j,1}],'','Amplitude',...
                0,... % save
                1,... % show
                path,'overlap',channel(1,i),'histFitPlot'); % plot the histogram with fit distribution the feature of each class
            for k = 1:numClass
                hHist(k,1).Color = colorArray(k,:);
            end
            l(j,i) = legend(hHist,xTickValue);
        end
    end
    for i = 1:numChannel
        [~,fSHist(i,1)] = plots2subplots(pHist(:,i),2,4);
        legend(xTickValue);
        if saveHistFit
            savePlot(path,'Distribution of Features',plotFileName,['Distribution of features of channel ',num2str(i)])
        end
        if ~showHistFit
            close
        end
    end
    delete(fHist) % delete the separated plot
end


end

