function [] = plotAccuracy(classifierOutput,featureIndex,plotFileName,path,numClass,xScale,xTickValue,displayInfo,numChannel,is2DClassification,channel,titleName)
%plotAccuracy Plot accuracy in visualizeFeatures
%   [] = plotAccuracy(classificationOutput,numFeatureCombination,accuracyBasicParameter,featureIndex,plotFileName,path,numClass,xScale,xTickValue,displayInfo,numChannel,is2DClassification,channel)

accuracyBasicParameter = classifierOutput.accuracyBasicParameter; % accuracy
numFeatureCombination = length(accuracyBasicParameter); % number of feature combinations
numRepetition = length(classifierOutput.classificationOutput{1,1}(1,1).accuracyAll{1,1});

selectedFeatureCombination = [2,8,14:18]; % select specific feature combinations to analyse
featureIndex{2,1} = featureIndex{2,1}(selectedFeatureCombination,:);
accuracyBasicParameter{2,1} = accuracyBasicParameter{2,1}(selectedFeatureCombination);
classifierOutput.classificationOutput{2,1} = classifierOutput.classificationOutput{2,1}(selectedFeatureCombination);

for i = 1:numFeatureCombination
    numCombination(i,1) = length(accuracyBasicParameter{i,1}); % number of combination
    featureIndexTemp = featureIndex{i,1};
    meanTemp{i,1} = vertcat(accuracyBasicParameter{i,1}.mean);
    stdeTemp = vertcat(accuracyBasicParameter{i,1}.stde);
    pA = plotFig(1:numCombination(i,1),meanTemp{i,1},plotFileName,['Accuracy with ',num2str(i),' features in combinations'],'Feature Combinations','Acurracy',0,1,path,'overlap',0,'barStackedPlot');
    hold on
    pA.XTick = 1:numCombination(i,1);
    pA.XTickLabel = checkMatNAddStr(featureIndexTemp,',',1);
    xLimit = xlim;
    ylim([0,1]);
    grid on
    cp = plot(xLimit,[1/numClass,1/numClass],'k--'); % plot chance performance
    legend('channel 14','channel 16','chance performance');
    errorbar(getErrorBarXAxisValues(numCombination(i,1),numChannel),meanTemp{i,1},stdeTemp,'r*'); % error bar
    if displayInfo.saveAccuracy
        savePlot(path,'Accuracy of Features Combination',plotFileName,['Accuracy of ',titleName,' with ',num2str(i),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
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
        pS = plotFig(1:numCombination(end,1),vertcat(synergyParameters(:,i).mean),plotFileName,['Synergy with ',num2str(numFeatureCombination),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',',2)],'Features Combinations','Acurracy',0,displayInfo.showAccuracy,path,'overlap',channel(1,i),'barPlot');
        hold on
        labelPlot(pS,find(significance(:,i)==1),'r^'); % label asteric on the barchart if it is significantly difference
        errorbar(1:numCombination(end,1),vertcat(synergyParameters(:,i).mean),vertcat(synergyParameters(:,i).stde),'r*');
        set(pS,'XTick',1:numCombination(end,1),'XTickLabel',checkMatNAddStr(featureIndex{2,1},',',1));
        grid on
        if displayInfo.saveAccuracy
            savePlot(path,'Synergy',plotFileName,['Synergy of ',titleName,' of channel ',num2str(channel(i)),'  with ',num2str(numFeatureCombination),' features in combinations with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~displayInfo.showAccuracy
            close
        end
    end
else
    warning('No combination of two features is used, thus no synergy is plotted...')
end


end

