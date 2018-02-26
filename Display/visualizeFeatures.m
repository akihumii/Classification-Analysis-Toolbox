function [] = visualizeFeatures(iter, path, classifierOutput, featuresInfo, signalInfo, displayInfo)
%visualizeFeatures Visualize the features, accuracies, feature distribution
%    [] = visualizeFeatures(iter, path, channel, classificationOutput, featureIndex, accuracyBasicParameter, featuresInfo, titleName, fileName, signalInfo, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures, saveHistFit, showHistFit, saveAccuracy, showAccuracy)

%% Parameters
[numClass, numFeatures, numChannel] = size(featuresInfo.featuresAll); % the sizes of the features properties
accuracyBasicParameter = classifierOutput.accuracyBasicParameter;
numFeatureCombination = length(accuracyBasicParameter);
titleName = classifierOutput.classifierTitle;
fileName = signalInfo(1,1).fileName;
numRowSubplots = 4; % for the row of subplots in overall plots
channel = signalInfo(1,1).signal.channel;
featureIndex = classifierOutput.featureIndex;
is2DClassification = length(featureIndex) == 2; % if 2 features are used in the combination to do the classification
colorArray = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840];

if numClass == 3
    xTickValue{3,1} = 'Noise';
end

%% Preparation
switch titleName
    case 'Different Speed'
        plotFileName = [fileName(1:6),fileName(12:17)];
        xScale = 'Speed';
        xTickValue = cat(1,signalInfo(:,1).fileSpeed);
    case 'Different Day';
        plotFileName = fileName(1:8);
        xScale = 'Week';
        xTickValue = cat(1,signalInfo(:,1).fileDate);
    case 'Active EMG'
        plotFileName = fileName;
        xScale = '';
        xTickValue = [{'non-activated EMG'};{'activated EMG'}];
end

%% Plot Features
if displayInfo.showFigures || displayInfo.saveFigures || displayInfo.showSeparatedFigures || displayInfo.saveSeparatedFigures
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

%% Plot Accuracy
if displayInfo.showAccuracy || displayInfo.saveAccuracy
    numRepetition = length(classifierOutput.classificationOutput{1,1}(1,1).accuracyAll{1,1});
    
    for i = 1:numFeatureCombination
        numCombination(i,1) = length(accuracyBasicParameter{i,1}); % number of combination
        featureIndexTemp = featureIndex{i,1};
        meanTemp{i,1} = vertcat(accuracyBasicParameter{i,1}.mean);
        stdeTemp = vertcat(accuracyBasicParameter{i,1}.stde);
        pA = plotFig(1:numCombination(i,1),meanTemp{i,1},plotFileName,['Accuracy with ',num2str(i),' features in combinations'],'Feature Combinations','Acurracy',0,1,path,'overlap',0,'barStackedPlot');
        hold on
        pA.XTick = 1:numCombination(i,1);
        pA.XTickLabel = num2cell(num2str(featureIndexTemp),2);
        xLimit = xlim;
        ylim([0,1]);
        grid on
        cp = plot(xLimit,[1/numClass,1/numClass],'k--'); % plot chance performance
        legend('channel 14','channel 16','chance performance');
        errorbar(getErrorBarXAxisValues(numCombination(i,1),numChannel),meanTemp{i,1},stdeTemp,'r*'); % error bar
        if displayInfo.saveAccuracy
            savePlot(path,'Accuracy of Features Combination',plotFileName,['Accuracy with ',num2str(i),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~displayInfo.showAccuracy
            close
        end
    end
    
    %% plot Synergy
    if is2DClassification
        for i = 1:numChannel
            for j = 1:numCombination(end,1)
                [synergyParameters(j,i),significance(j,i)] = calculateSynergy([classifierOutput.classificationOutput{1,1}(featureIndex{2,1}(j,1)).accuracyAll(i,1);classifierOutput.classificationOutput{1,1}(featureIndex{2,1}(j,2)).accuracyAll(i,1)],classifierOutput.classificationOutput{2,1}(j,1).accuracyAll{i,1},numRepetition);
            end
            pS = plotFig(1:numCombination(end,1),vertcat(synergyParameters(:,i).mean),plotFileName,['Synergy with ',num2str(numFeatureCombination),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')],'Features Combinations','Acurracy',0,displayInfo.showAccuracy,path,'overlap',channel(1,i),'barPlot');
            hold on
            labelPlot(pS,find(significance(:,i)==1),'r^'); % label asteric on the barchart if it is significantly difference
            errorbar(1:numCombination(end,1),vertcat(synergyParameters(:,i).mean),vertcat(synergyParameters(:,i).stde),'r*');
            set(pS,'XTick',1:numCombination(end,1),'XTickLabel',num2cell(num2str(featureIndex{2,1}),2));
            grid on
            if displayInfo.saveAccuracy
                savePlot(path,'Synergy',plotFileName,['Synergy of channel ',num2str(channel(i)),'  with ',num2str(numFeatureCombination),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
            end
            if ~displayInfo.showAccuracy
                close
            end
        end
    else
        warning('No combination of two features is used, thus no synergy is plotted...')
    end
end

%% Plot histogram and distribution
if displayInfo.showHistFit || displayInfo.saveHistFit
    %% (for single features in all classes)
    for i = 1:numChannel
        for j = 1:numFeatures
            featuresTemp = cell2nanMat(featuresInfo.featuresAll(:,j,i)); % reconstruct the same features from all classes into a matrix
            [pHist(j,i),fHist(j,i),hHist] = plotFig(0,featuresTemp,plotFileName,['Distribution of ',featuresInfo.featuresNames{j,1}],'','Amplitudes',0,1,path,'overlap',channel(1,i),'histFitPlot'); % plot the histogram with fit distribution the feature of each class
            hold on
            for k = 1:numClass
                hHist{k,1}(1,1).FaceColor = colorArray(k,:);
                hHist{k,1}(2,1).Color = colorArray(k,:);
                hHistTemp(k,1) = hHist{k,1}(2,1);
            end
            l(j,i) = legend(hHistTemp,xTickValue);
            
            % plot classifier's boundary
            constTemp(1,1) = classifierOutput.classificationOutput{1,1}(j,1).coefficient{i,1}(1,2).const; % first and second class constant
            linearTemp(1,:) = classifierOutput.classificationOutput{1,1}(j,1).coefficient{i,1}(1,2).linear; % first and second class linear
            plotBoundary(pHist(j,i),constTemp,linearTemp);
        end
    end
    % plot all the graphs in a same figure
    for i = 1:numChannel
        [~,fSHist(i,1)] = plots2subplots(pHist(:,i),numRowSubplots,numFeatures/numRowSubplots);
        pHistTemp = gca;
        legend(flipud(pHistTemp.Children(1:2:end,1)),[xTickValue;{'Classifier''s boudary'}]);
        if displayInfo.saveHistFit
            savePlot(path,'Distribution of Features',plotFileName,['Distribution of features of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~displayInfo.showHistFit
            close
        end
    end
    delete(fHist) % delete the separated plot
    clear featuresTemp numFeatures constantTemp linearTemp
    
    %% for 2 features used in combinations
    if is2DClassification
        featureIndexTemp = [1,3;1,3]; % features used in combinations, channels are separated in rows
        for i = 1:numChannel
            for j = 1:2
                featuresTemp{j,1} = featuresInfo.featuresAll(:,featureIndexTemp(i,j),i);
                featuresTemp{j,1} = cell2nanMat(featuresTemp{j,1});
            end
            pScatter = plotFig(featuresTemp{1,1},featuresTemp{2,1},plotFileName,['Distribution of 2 Features ( ',checkMatNAddStr(featuresInfo.featuresNames(featureIndexTemp(i,:)),' , '),' ) of ',plotFileName,' ch ',num2str(channel(1,i))],featuresInfo.featuresNames(featureIndexTemp(i,1)),featuresInfo.featuresNames(featureIndexTemp(i,2)),0,1,path,'overlap',channel(1,i),'scatterPlot'); % plot the scattered points distribution of the feature of each class;
            hold all
            grid on
            
            numFeatures = size(featureIndex{2,1},1);
            featuresLocsTemp = repmat(featureIndexTemp(i,:),numFeatures,1) == featureIndex{2,1};
            featuresLocsTemp = find(all(featuresLocsTemp,2));
            
            constTemp(1,1) = classifierOutput.classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).const; % first and second class constant
            linearTemp(1,:) = classifierOutput.classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).linear; % first and second class linear
            if numClass > 2
                constTemp(2,1) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).const; % second and third class constant
                linearTemp(2,:) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).linear; % second and third class linear
                constTemp(3,1) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).const; % first and third class constant 
                linearTemp(3,:) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).linear; % first and third class linear
            end
            plotBoundary(pScatter,constTemp,linearTemp);
            
            lineTemp = gca;
            lineTemp = flipud(lineTemp.Children(1:(numClass*(numClass-1)/2)));
            for j = 1:length(lineTemp)
                lineTemp(j,1).Color = colorArray(j,:);
            end
            
            if numClass == 2
                legend(flipud(pScatter.Children),xTickValue{:},checkMatNAddStr(xTickValue(:,1),' , '));
            elseif numClass == 3
                legend(flipud(pScatter.Children),xTickValue{:},checkMatNAddStr(xTickValue(1:2,1),' , '),checkMatNAddStr(xTickValue(2:3,1),' , '),checkMatNAddStr(xTickValue([1,3],1),' , '));
            end
            
            if displayInfo.saveHistFit
                savePlot(path,'Distribution of 2 Features',plotFileName,['Distribution of features ( ',checkMatNAddStr(featuresInfo.featuresNames(featureIndexTemp(i,:)),' , '),' )  of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
            end
            
        end
    end
end

end

