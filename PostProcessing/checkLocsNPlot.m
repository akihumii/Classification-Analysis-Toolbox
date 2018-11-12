function checkLocsNPlot(data,classifiedInd,parameters,threshold)
%CHECKLOCSNPLOT Check the prediction and true classes after running
%characteriseClassifier.m
% 
% function checkLocsNPlot(dataFiltered{1,1},predictClass,trueClass,parameters,threshold)

figure
plot(data)
hold on

yLimit = ylim';
% plot(repmat(predictClass,1,2)*yLimit(2),'r-','lineWidth',2)
% plot(repmat(trueClass,1,2)*yLimit(2),'g-','lineWidth',2)
a = 1 : parameters.overlapWindowSize : length(data) - parameters.movingWindowSize;
plot(repmat(a,2,1),ylim,'k-')

stem(repmat(classifiedInd{1,2},2,1),repmat(yLimit,1,length(classifiedInd{1,2})),'r','lineWidth',2)
hold on
stem(repmat(classifiedInd{2,2},2,1),repmat(yLimit,1,length(classifiedInd{2,2})),'g','lineWidth',2)

plot(data,'b')

plot(xlim,repmat(threshold,1,2),'k');

end