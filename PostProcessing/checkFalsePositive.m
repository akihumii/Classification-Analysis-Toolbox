clear
%% parameters
iTarget = 4;  % target axis
predictionTarget = 2;  % target prediction
% plotTN = 1;  % include TN in confusion matrix
% bufferTiming = 0.05;  % buffer to increase the size of prediction (seconds)
overlappingTime = 0.05;  % overlapping timing during online calssification

titleConfusionMat = sprintf('Biceps Multi-Channel Classification');  % confusion matrix title

%%
currentFig = gcf;
data = flipud(findall(currentFig, 'Type', 'axes'));
samplingFreq = 1250;

%% target
endPoint = data(iTarget).Children(1).XData * samplingFreq;
startingPoint = data(iTarget).Children(2).XData * samplingFreq;
numBursts = length(startingPoint);
burstLocs = [startingPoint; endPoint];

lengthDataTarget = length(data(iTarget).Children(3).YData);
overlappingSampleUnit = overlappingTime * samplingFreq;
steps = floor(1 : overlappingSampleUnit : lengthDataTarget);
numSteps = length(steps);

%% get the classes
% get the target class
targetClass = zeros(size(steps));
for i = 1:numBursts
    targetClass = or(targetClass, steps >= burstLocs(1,i) & steps <= burstLocs(2,i));
end
targetClass = targetClass * predictionTarget;

% get the prediciton class
dataPrediction = data(end).Children.YData;
predictionClass = zeros(size(steps));
for i = 1:numSteps
    predictionClass(1,i) = dataPrediction(1, steps(1,i));
end

%%
figure
targetConfusion = mat2confusionMat(targetClass);
predictionConfusion = mat2confusionMat(predictionClass);

% edit targetConfusion into size of predictionConfusion
uniquePrediction = unique(predictionClass);
uniqueTarget = unique(targetClass);
numMissingClass = sum(~ismember(uniquePrediction, uniqueTarget));
targetConfusion = [targetConfusion(1,:); zeros(numMissingClass, size(targetConfusion,2)); targetConfusion(2,:)];

plotconfusion(targetConfusion, predictionConfusion);
hConfusion = gca;
hConfusion.Title.String = titleConfusionMat;


% TP = sum(targetClass == predictionTarget & predictionClass == predictionTarget);
% TN = sum(targetClass == 0 & predictionClass == 0);
% FP = predictionClass(targetClass == 0 & predictionClass ~= 0);


% dataTarget = dataTarget * samplingFreq;
% numDataTarget = length(dataTarget);
% 
% % prediction
% 
% predictionUnique = unique(prediction);
% numPredictionUnique = length(predictionUnique);
% 
% predictionFN = zeros(size(dataTarget));
% for n = 1:numPredictionUnique
%     if predictionUnique(1,n) ~= 0
%         [predictionTargetP{n,1}, predictionTargetF{n,1}, predictionFN] = getTPnFP(prediction, dataTarget, predictionFN, bufferTiming, samplingFreq, predictionUnique(1,n));
%     end
% end
% predictionTargetF = cell2nanMat(predictionTargetF(2:end, 1));
% predictionTargetF = predictionTargetF(~isnan(predictionTargetF));
% 
% predictionTargetP = cell2nanMat(predictionTargetP(2:end, 1));
% predictionTargetP = predictionTargetP(~isnan(predictionTargetP));
% 
% %% confusion matrix
% matPrediction = mat2confusionMat(predictionTargetP);  % prediction based on target
% matPrediction = [zeros(1, size(matPrediction, 2)); matPrediction];
% matTarget = zeros(numPredictionUnique, size(matPrediction, 2));  % target
% predictionTargetLocs = predictionUnique == predictionTarget;
% matTarget(predictionTargetLocs, :) = 1;  % mark the correct target
% 
% % get false negative
% [matTarget, matPrediction] = appendFN(predictionFN, matTarget, matPrediction, predictionTargetLocs);
% 
% % get false postitive
% [matTarget, matPrediction] = appendFP(predictionTargetF, matTarget, matPrediction);
% 
% % get true negative
% [matTarget, matPrediction] = appendTN(matTarget, matPrediction);
% 
% % plot confusion matrix
% 
% figure
% plotconfusion(matTarget, matPrediction);
% hConfusionMat = gca;
% hConfusionMat.XTickLabel = cellstr([num2str(predictionUnique');' ']);
% hConfusionMat.YTickLabel = cellstr([num2str(predictionUnique');' ']);
% hConfusionMat.Title.String = titleConfusionMat;
% 
% % locsFN = dataTarget(~ismember(dataTarget, locsTP));
% % numFN = length(locsFN);
% 
% % disp(sprintf('TP: %d/%d \nFN: %d/%d \nFP: %d/%d' , TP, numDataTarget, numFN, numDataTarget, FP, numLocs))
% function [predictionTargetP, predictionTargetF, predictionFN] = getTPnFP(prediction, dataTarget, predictionFN, bufferTiming, samplingFreq, predictionUnique)
% locs = prediction == predictionUnique;
% locsDiff = diff(locs);
% locsStart = find(locsDiff == 1);
% locsEnd = find(locsDiff == -1);
% 
% numLocs = length(locsStart);
% 
% % locsTP = [];
% % locsFP = [];
% predictionTargetPTemp = 0;
% predictionTargetFTemp = 0;
% for i = 1:numLocs
%     rangeTemp = floor(locsStart(1,i)-bufferTiming*samplingFreq : locsEnd(1,i)+bufferTiming*samplingFreq);
%     numWindow = ceil(length(rangeTemp)/(0.05 * samplingFreq));
%     checking = ismember(floor(dataTarget), rangeTemp);  % prediction of burst
%     predictionFN = or(predictionFN, checking);
%     if any(checking)
% %         predictionClass(1,checking == 1) = predictionUnique;
%         predictionTargetPTemp = predictionTargetPTemp + numWindow;
% %         locsTP(1,checking == 1) = dataTarget(checking == 1);
%     else
% %         FP(1,i) = predictionUnique;
%         predictionTargetFTemp = predictionTargetFTemp + numWindow;
% %         locsFP(n,i) = locsStart(1,i);
%     end
% end
% predictionTargetP = predictionUnique * ones(1, predictionTargetPTemp);
% predictionTargetF = predictionUnique * ones(1, predictionTargetFTemp);
% end
% 
% function [matTarget, matPrediction] = appendFP(predictionTargetF, matTarget, matPrediction)
% predictionTargetF = mat2confusionMat(predictionTargetF);
% predictionTargetF = [zeros(1,size(predictionTargetF,2)); predictionTargetF];
% 
% matTargetTemp = zeros(size(predictionTargetF));
% matTargetTemp(1,:) = 1;
% matTarget = [matTarget, matTargetTemp];
% matPrediction = [matPrediction, predictionTargetF];
% end
% 
% function [matTarget, matPrediction] = appendFN(predictionFN, matTarget, matPrediction, predictionTargetLocs)
% numFN = sum(predictionFN == 0);
% 
% matTargetTemp = zeros(size(matTarget,1), numFN);
% matTargetTemp(predictionTargetLocs,:) = 1;
% matPredictionTemp = zeros(size(matTarget, 1), numFN);
% matPredictionTemp(1,:) = 1;
% 
% matTarget = [matTarget, matTargetTemp];
% matPrediction = [matPrediction, matPredictionTemp];
% end
% 
% function [matTarget, matPrediction] = appendTN(matTarget, matPrediction)
% matTemp = zeros(size(matPrediction));
% matTemp(1,:) = 1;
% 
% matTarget = [matTarget, matTemp];
% matPrediction = [matPrediction, matTemp];
% end
