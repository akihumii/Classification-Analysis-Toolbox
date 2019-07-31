clear
%% parameters
activationPattern = [   0,0,0,0;...
                        1,0,0,0;...
                        0,1,0,0;...
                        1,1,0,0;...
                        0,0,1,0;...
                        0,0,0,1;...
                        0,0,1,1];
activationClass = [ 0,...
                    1,...
                    1,...
                    1,...
                    2,...
                    2,...
                    2];
labelConfusion = {'baseline';...
                  'biceps';...
                  'triceps';...
                  'others'};
changePredictionFlag = getYesNo;
overlappingTime = 0.05;  % overlapping timing during online calssification
editConfusion = 'minus';  % 'minus' or 'add'

titleConfusionMat = sprintf('Multi-Channel Classification');  % confusion matrix title

%%
currentFig = getFig();
data = flipud(findall(currentFig, 'Type', 'axes'));
samplingFreq = 1250;

%% target
burstLocs = cell(4,1);
for i = 1:4
    if length(data(i).Children) > 1
        burstLocs{i,1} = transpose([data(i).Children(2).XData; data(i).Children(1).XData]*samplingFreq);
    else
        burstLocs{i,1} = [];
    end
end
burstLocs = cell2nanMat(burstLocs);

lengthDataTarget = length(data(end).Children.YData);
overlappingSampleUnit = overlappingTime * samplingFreq;
stepping = floor(1 : overlappingSampleUnit : lengthDataTarget);
numSteps = length(stepping);

%% get the classes
if changePredictionFlag
    [files, path] = selectFiles('Select prediction file...');
    data(end).Children.YData = transpose(dlmread(fullfile(path, files{1,1}),','));
end
dataPrediction = data(end).Children.YData;
targetClass = zeros(size(stepping));
predictionClass = zeros(size(stepping));
outlierClass = max(activationClass) + 1;
for i = 1:numSteps
    activationTemp = any(squeeze(stepping(1,i) > burstLocs(:,1,:) & stepping(1,i) < burstLocs(:,2,:)));
    activationLocs = all(activationTemp == activationPattern, 2);
    if any(activationLocs)
        activationClassTemp = activationClass(activationLocs);
    else
        activationClassTemp = outlierClass;
    end
    targetClass(1,i) = activationClassTemp;
    predictionClass(1,i) = dataPrediction(1, stepping(1,i));
end

%% Subsample baseline
% numTargetPrediction = sum(targetClass == predictionTarget);
% notTNLocs = ~(targetClass == 0 & predictionClass == 0);
% targetClass = targetClass(notTNLocs);
% predictionClass = predictionClass(notTNLocs);
% targetClass = [targetClass, zeros(1, numTargetPrediction)];
% predictionClass = [predictionClass, zeros(1, numTargetPrediction)];

%% confusion
figure
targetConfusion = mat2confusionMat(targetClass);
predictionConfusion = mat2confusionMat(predictionClass);

% edit targetConfusion into size of predictionConfusion
uniquePrediction = unique(predictionClass);
uniqueTarget = unique(targetClass);
arrayLabel = 0:length(labelConfusion)-1;

if strcmp(editConfusion, 'add')
    predictionConfusion = addClass(predictionConfusion, ~ismember(arrayLabel, uniquePrediction));
    targetConfusion = addClass(targetConfusion, ~ismember(arrayLabel, uniqueTarget));
else
    locsMinus = minusClass(targetConfusion, ~ismember(uniqueTarget, uniquePrediction));
    predictionConfusion(:, locsMinus) = [];
    targetConfusion(~ismember(arrayLabel, uniquePrediction), :) = [];
    targetConfusion(:, locsMinus) = [];
end
    
plotconfusion(targetConfusion, predictionConfusion);
hConfusion = gca;
hConfusion.Title.String = titleConfusionMat;
arrayActivation = 1:size(targetConfusion,1);
hConfusion.XTickLabel(arrayActivation) = labelConfusion(arrayActivation);
hConfusion.YTickLabel(arrayActivation) = labelConfusion(arrayActivation);

function output = addClass(oldArray, locs)
    output = insertIntoArray(zeros(1, size(oldArray, 2)), oldArray, locs, 1);
end

function locsAll = minusClass(oldArray, locs)
    locsTemp = find(locs == 1);
    locsAll = [];
    for i = 1:length(locsTemp)
        arrayTemp = oldArray(locsTemp(i), :);
        locsAll = [locsAll, find(arrayTemp == 1)];
    end
end

function output = getYesNo()
    opts.Interpreter = 'tex';
    opts.Default = 'No';
    quest = 'Use a new prediction?';
    output = questdlg(quest, 'A question...', 'Yes','No',opts);
    switch output
        case 'Yes'
            output = 1;
        case 'No'
            output = 0;
    end
end

function fig = getFig()
    [files, path] = selectFiles('Select data figure with prediction');
    fig = openfig(fullfile(path,files{1,1}));
end
