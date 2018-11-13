function p = checkLocsNPlot(data,accuracyInfo,parameters,threshold)
%CHECKLOCSNPLOT Check the prediction and true classes after running
%characteriseClassifier.m
% 
% function checkLocsNPlot(dataFiltered{1,1},predictClass,trueClass,parameters,threshold)

p = figure;
plot(data)
hold on

yLimit = ylim';
% plot(repmat(predictClass,1,2)*yLimit(2),'r-','lineWidth',2)
% plot(repmat(trueClass,1,2)*yLimit(2),'g-','lineWidth',2)
a = 1 : parameters.overlapWindowSize : length(data) - parameters.movingWindowSize;
plot(repmat(a,2,1),ylim,'k-')

stem(repmat(accuracyInfo.classifiedInd{1,2},2,1),repmat(yLimit,1,length(accuracyInfo.classifiedInd{1,2})),'r','lineWidth',2)
hold on
stem(repmat(accuracyInfo.classifiedInd{2,2},2,1),repmat(yLimit,1,length(accuracyInfo.classifiedInd{2,2})),'g','lineWidth',2)

plot(data,'b')

plot(xlim,repmat(threshold,1,2),'k');


figure
plotconfusion(accuracyInfo.predictClassMat,accuracyInfo.burstExistsFlagMat)

end