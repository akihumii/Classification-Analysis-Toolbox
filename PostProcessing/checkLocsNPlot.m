function checkLocsNPlot(data,accuracyInfo,parameters,path)
%CHECKLOCSNPLOT Check the prediction and true classes after running
%characteriseClassifier.m
%
% function checkLocsNPlot(data{i,1}Filtered{1,1},predictClass,trueClass,parameters,threshold,plotConfusionFlag,path)
iters = length(accuracyInfo);

for i = 1:iters
    titleNameStem = [num2str(parameters.movingWindowSize),' ms window size Stem Plot Channel ',num2str(i)];
    titleNameConfusionMat = [num2str(parameters.movingWindowSize),' ms window size Confusion Matrix Channel ',num2str(i)];
    
    pS = plotFig((1:length(data{i,1}))/parameters.samplingFreq,data{i,1},'',titleNameStem,'Time (s)','Amplitude (V)',0,1);
    hold on
    
    yLimit = ylim';
%     gridArray = parameters.movingWindowSize/parameters.samplingFreq : parameters.overlapWindowSize/parameters.samplingFreq : length(data{i,1})/parameters.samplingFreq;
%     plot(repmat(gridArray,2,1),ylim,'k-')

    TP = plot((repmat(accuracyInfo(i,1).classifiedInd{2,2},2,1) * parameters.overlapWindowSize + parameters.movingWindowSize)/parameters.samplingFreq,...
        repmat(yLimit,1,length(accuracyInfo(i,1).classifiedInd{2,2})),'g','lineWidth',2);     
    FP = plot((repmat(accuracyInfo(i,1).classifiedInd{1,2},2,1) * parameters.overlapWindowSize + parameters.movingWindowSize)/parameters.samplingFreq,...
        repmat(yLimit,1,length(accuracyInfo(i,1).classifiedInd{1,2})),'r','lineWidth',2);
    FN = plot((repmat(accuracyInfo(i,1).classifiedInd{2,1},2,1) * parameters.overlapWindowSize + parameters.movingWindowSize)/parameters.samplingFreq,...
        repmat(yLimit,1,length(accuracyInfo(i,1).classifiedInd{2,1})),'b','lineWidth',2);
    TN = plot((repmat(accuracyInfo(i,1).classifiedInd{1,1},2,1) * parameters.overlapWindowSize + parameters.movingWindowSize)/parameters.samplingFreq,...
        repmat(yLimit,1,length(accuracyInfo(i,1).classifiedInd{1,1})),'Color',[211,211,211]/255,'lineWidth',1);
    
    plot((1:length(data{i,1}))/parameters.samplingFreq,data{i,1},'b')
    
    legendObj = [plot(nan,nan,'g','LineWidth',2), plot(nan,nan,'r','LineWidth',2), plot(nan,nan,'b','LineWidth',2), plot(nan,nan,'Color',[211,211,211]/255,'LineWidth',2)];
    legendName = {['TP = ',num2str(length(TP))],['FP = ',num2str(length(FP))],['FN = ',num2str(length(FN))],['TN = ',num2str(length(TN))]};
    
    legend(legendObj,legendName);
    
    % Saving & Showing
    if parameters.savePlotFlag
        savePlot(path,'Stem Plot',titleNameStem,titleNameStem);
    end
    if ~parameters.showPlotFlag
        delete(pS)
    end
    
    %% Confusion matrix
    pC = plotconfusion(accuracyInfo(i,1).predictClassMat,accuracyInfo(i,1).burstExistsFlagMat);
    title(titleNameConfusionMat)
    
    % Saving & Showing
    if parameters.savePlotFlag
        savePlot(path,'Confusion Matrix',titleNameConfusionMat,titleNameConfusionMat);
    end
    if ~parameters.showPlotFlag
        delete(pC)
    end

end
end