function [] = visualizeFeatures(iter, path, channel, classificationOutput, featureIndex, accuracyBasicParameter, featuresAll, featureStde, titleName, fileName, fileSpeed, fileDate, featureMean, featuresNames, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures, saveHistFit, showHistFit, saveAccuracy, showAccuracy)
%visualizeFeatures Visualize the features, accuracies, feature distribution
%   [] = visualizeFeatures(iter, path, channel, featureIndex, accuracyBasicParameter, featuresAll, featureStde, titleName, fileName, fileSpeed, fileDate, featureMean, featuresNames, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures, saveHistFit, showHistFit, saveAccuracy, showAccuracy)

switch titleName
    case 'Different Speed'
        plotFileName = [fileName{1,1}(1:6),fileName{1,1}(12:17)];
        xScale = 'Speed';
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
numRowSubplots = 2; % for the row of subplots in overall plots
colorArray = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840];

if numClass > 2
    xTickValue{1,1} = 'Noise';
end

if showFigures || saveFigures || showSeparatedFigures || saveSeparatedFigures
    for i = 1:numFeatures
        for j = 1:numChannel
            [p(i,j),f(i,j)] = plotFig(1:iter,transpose(featureMean(i,:,j)),plotFileName,featuresNames{i,1},xScale,'',0,1,path, 'subPlot',channel(1,j),'barPlot');
            p(i,j).XTick = 1:iter;
            p(i,j).XTickLabel = xTickValue;
            hold on
            errorbar(1:iter,transpose(featureMean(i,:,j)),featureStde(i,:,j),'r*');
            
            if saveSeparatedFigures
                savePlot(path,['Features sorted in ',titleName,],plotFileName,[featuresNames{i,1},' with ',titleName,' of ch ',num2str(channel(1,j)),' in ',plotFileName, ' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
            end
            
        end
    end
    
    %% Plot all the features
    for i = 1:numChannel
        [~,fS(i,1)] = plots2subplots(p(:,i),numRowSubplots,numFeatures/numRowSubplots);
        if saveFigures
            savePlot(path,['Features sorted in ',titleName,],plotFileName,['All the Features with ',titleName,' of ch ',num2str(channel(1,i)),' in ',plotFileName,' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
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
        pA = plotFig(1:numCombination,meanTemp,plotFileName,['Accuracy with ',num2str(i),' features in combinations'],'Feature Combinations','Amplitude',0,1,path,'overlap',0,'barStackedPlot');
        hold on
        legend('channel 14','channel 16');
        pA.XTick = 1:numCombination;
        pA.XTickLabel = num2cell(num2str(featureIndexTemp),2);
        ylim([0,1]);
        grid on
        errorbar(getErrorBarXAxisValues(numCombination,numChannel),meanTemp,stdeTemp,'r*');
        if saveAccuracy
            savePlot(path,'Accuracy of Features Combination',plotFileName,['Accuracy with ',num2str(i),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~showAccuracy
            close
        end
    end
end
%% Plot histogram and distribution 
if showHistFit || saveHistFit
    %% (for single features in all classes)
    for i = 1:numChannel
        for j = 1:numFeatures
            featuresTemp = cell2nanMat(featuresAll(:,j,i)); % reconstruct the same features from all classes into a matrix
            [pHist(j,i),fHist(j,i),hHist] = plotFig(0,featuresTemp,plotFileName,['Distribution of ',featuresNames{j,1}],'','Amplitude',0,1,path,'overlap',channel(1,i),'histFitPlot'); % plot the histogram with fit distribution the feature of each class
            for k = 1:numClass
                hHist(k,1).Color = colorArray(k,:);
            end
            l(j,i) = legend(hHist,xTickValue);
        end
    end
    for i = 1:numChannel
        [~,fSHist(i,1)] = plots2subplots(pHist(:,i),numRowSubplots,numFeatures/numRowSubplots);
        legend(xTickValue);
        if saveHistFit
            savePlot(path,'Distribution of Features',plotFileName,['Distribution of features of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~showHistFit
            close
        end
    end
    delete(fHist) % delete the separated plot
    clear featuresTemp numFeatures
    
    %% for 2 features used in combinations
    featureIndexTemp = [5,8;2,4]; % features used in combinations, channels are separated in rows
    for i = 1:numChannel
        for j = 1:2
        featuresTemp{j,1} = featuresAll(:,featureIndexTemp(i,j),i);
        featuresTemp{j,1} = cell2nanMat(featuresTemp{j,1});
        end
        pScatter = plotFig(featuresTemp{1,1},featuresTemp{2,1},plotFileName,'Distribution of features','','Amplitude',0,1,path,'overlap',channel(1,i),'scatterPlot'); % plot the scattered points distribution of the feature of each class;
        hold on
        grid on
        
        numFeatures = size(featureIndex{2,1},1);
        featuresLocsTemp = repmat(featureIndexTemp(i,:),numFeatures,1) == featureIndex{2,1};
        featuresLocsTemp = find(all(featuresLocsTemp,2));
        
        constTemp(1,1) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).const; % first and second class
        linearTemp(1,:) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).linear; % first and second class 
        if numClass > 2
            constTemp(2,1) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).const; % second and third class
            linearTemp(2,:) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).linear; % second and third class
            constTemp(3,1) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).const; % first and third class
            linearTemp(3,:) = classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).linear; % first and third class
        end
        pBoundary = plotBoundary(pScatter,constTemp,linearTemp);
        title(['Distribution of 2 Features ( ',checkMatNAddStr(featuresNames(featureIndexTemp(i,:)),' , '),' ) of ',plotFileName,' ch ',num2str(channel(1,i))]);
        if numClass == 2
            legend(xTickValue{:},checkMatNAddStr(xTickValue(:,1),' , '));
        elseif numClass == 3
            for j = 1:numClass
                pBoundary(j,1).Color = colorArray(j,:);
            end
        legend(xTickValue{:},checkMatNAddStr(xTickValue(1:2,1),' , '),checkMatNAddStr(xTickValue(2:3,1),' , '),checkMatNAddStr(xTickValue([1,3],1),' , '));
        end
        
        if saveHistFit
            savePlot(path,'Distribution of 2 Features',plotFileName,['Distribution of features ( ',checkMatNAddStr(featuresNames(featureIndexTemp(i,:)),' , '),' )  of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end

    end
end

end

