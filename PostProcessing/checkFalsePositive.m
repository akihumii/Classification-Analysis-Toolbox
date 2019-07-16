clear
%% parameters
iTarget = 1;  % target axis
predictionTarget = 1;  % target prediction
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

%% Subsample baseline
numTargetPrediction = sum(targetClass == predictionTarget);
notTNLocs = ~(targetClass == 0 & predictionClass == 0);
targetClass = targetClass(notTNLocs);
predictionClass = predictionClass(notTNLocs);
targetClass = [targetClass, zeros(1, numTargetPrediction)];
predictionClass = [predictionClass, zeros(1, numTargetPrediction)];

%% confusion
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


