function output = dataClassificationPreparation(signal, iter, parameters)
%dataClassification Detect windows, extract features, execute
%classification
%   input: parameters: pcaCleaning, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, threshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType
%   output = dataClassificationPreparation(signal, iter, selectedWindow, windowSize, dataToBeDetectedSpike, spikeDetectionType, threshold, sign, treshStdMult, TKEOStartConsecutivePoints, TKEOEndConsecutivePoints,channelExtractStartingLocs,burstTrimming,burstTrimmingType)

% for the case of selected filtered data, because the values lies in the
% field 'values' of the structure 'dataFiltered'.

if isequal(parameters.overlappedWindow, 'dataFiltered')
    parameters.overlappedWindow = [{'dataFiltered'};{'values'}];
end

output(iter,1) = classClassificationPreparation; % pre-allocation

disp('Anaylizing...');

output = runPreparation(signal, output, parameters, iter);

%% optimize burst detection
optimizeFlag = parameters.optimizeTKEOFlag;
if optimizeFlag
    disp('Optimizing...')
    Mdl = getSVMLoss(output, parameters);  % check current loss
    loss = Mdl.oosLoss;
    
    timeit = tic;
    [parameters, change] = randomizeTKEOParameters(parameters);  % get new parameters
    output = runPreparation(signal, output, parameters, iter);
    Mdl = getSVMLoss(output, parameters);  % check new loss
    
    repCount = 1;
    deltaLossAll = ones(3,4);
    changeIndex = [1,1];
    [optimizeFlag, loss, lossOrig, deltaLossAll] = updateOptimizeFlag(loss, Mdl, parameters, repCount, changeIndex, deltaLossAll);
    toc(timeit);
    
    timeit = tic;
    while optimizeFlag
        [parameters, change, changeIndex] = editTKEOParameters(...
            lossOrig, deltaLossAll(changeIndex(1,1),changeIndex(1,2)), parameters, change, changeIndex);
        output = runPreparation(signal, output, parameters, iter);
        
        Mdl = getSVMLoss(output, parameters);  % check new loss
        [optimizeFlag, loss, lossOrig, deltaLossAll] = updateOptimizeFlag(loss, Mdl, parameters, repCount, changeIndex, deltaLossAll);
        [repCount, changeIndex] = updateCounter(repCount, changeIndex, deltaLossAll(changeIndex(1,1),changeIndex(1,2)));
        toc(timeit);
    end
end
end

function [optimizeFlag, loss, lossOrig, deltaLossAll] = updateOptimizeFlag(loss, Mdl, parameters, numRun, changeIndex, deltaLossAll)
deltaLoss = loss-Mdl.oosLoss;  % check delta loss
lossOrig = loss;
loss = Mdl.oosLoss;  % update loss
fprintf('Optimizing %d,%d  | Run %d | current loss: %.4f | delta loss: %.4f...\n',...
    changeIndex(1,1), changeIndex(1,2), numRun, loss, deltaLoss);...);
deltaLossAll(changeIndex(1,1), changeIndex(1,2)) = deltaLoss;
deltaLossChecking = deltaLossAll > parameters.deltaLossLimit;
optimizeFlag = loss > parameters.lossLimit && any(deltaLossChecking(:));
end

function [parameters, change] = randomizeTKEOParameters(parameters)
parameters.TKEOStartConsecutivePoints = multiplyValues(parameters.TKEOStartConsecutivePoints);
[parameters.TKEOStartConsecutivePoints, change(1,:)] = changeValues(parameters.TKEOStartConsecutivePoints, parameters.learningRate(1));

parameters.TKEOEndConsecutivePoints = multiplyValues(parameters.TKEOEndConsecutivePoints);
[parameters.TKEOEndConsecutivePoints, change(2,:)] = changeValues(parameters.TKEOEndConsecutivePoints, parameters.learningRate(2));

parameters.threshStdMult = multiplyValues(parameters.threshStdMult);
[parameters.threshStdMult, change(3,:)] = changeValues(parameters.threshStdMult, parameters.learningRate(3));
end

function output = runPreparation(signal, output, parameters, iter)
for i = 1:iter
    output(i,1) = classClassificationPreparation(signal(i,1).file,signal(i,1).path,parameters.windowSize); % create object 'output'
    
    % detect spikes
    if parameters.makeFirstFileBaseline && i == 1
        spikeDetectionTypeTemp = parameters.spikeDetectionType;
        parameters.spikeDetectionType = 'moving window baseline';
    end
    
    output(i,1) = detectSpikes(output(i,1), signal(i,1), parameters);
    
    if parameters.makeFirstFileBaseline && i == 1
        parameters.spikeDetectionType = spikeDetectionTypeTemp ;
    end
    
    
    % get windows around spikes
    output(i,1) = classificationWindowSelection(output(i,1), signal(i,1), parameters);
    
    % clean the bursts by running PCA
    if parameters.pcaCleaning
        output(i,1) = pcaCleanData(output(i,1));
    end
    
    % extract features
    output(i,1) = featureExtraction(output(i,1),signal(i,1).samplingFreq,[{'selectedWindows'};{'burst'}]); % [1 * number of windows * number of sets]
    
    % group features for classification
    output(i,1) = classificationGrouping(output(i,1),'maxValue',i,parameters.trainingRatio);
    
    % get a baseline as the third class
    if parameters.getBaselineFeatureFlag
        %     [dataValues, ~] = loadMultiLayerStruct(signal(i,1),parameters.overlappedWindow);
        output(i,1) = getBaselineFeature(output(i,1),signal(i,1).samplingFreq,signal(i,1).dataFiltered.values,parameters.baselineType,signal(i,1).dataTKEO.values);
    end
    
end
end