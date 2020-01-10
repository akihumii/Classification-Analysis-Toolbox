function [output, parameters] = dataClassificationPreparation(signal, iter, parameters)
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
if parameters.optimizeTKEOFlag
    disp('Optimizing...')
    objOptimize = classOptimizeTKEO;
    getSVMLoss(objOptimize, output, parameters);  % check current loss
    objOptimize.lossOrig = objOptimize.Mdl.oosLoss;
    
    timeit = tic;
    parameters = randomizeTKEOParameters(objOptimize, parameters);  % get new parameters
    output = runPreparation(signal, output, parameters, iter);
    getSVMLoss(objOptimize, output, parameters);  % check new loss
    
    updateOptimizeFlag(objOptimize, parameters);
    toc(timeit);
    
    timeit = tic;
    while objOptimize.optimizeFlag
        parameters = editTKEOParameters(objOptimize, parameters);
        output = runPreparation(signal, output, parameters, iter);
        
        getSVMLoss(objOptimize, output, parameters);  % check new loss
        updateOptimizeFlag(objOptimize, parameters);
        updateCounter(objOptimize, parameters);
        
        saveTKEOParameter(objOptimize, parameters);
        toc(timeit);
    end
    parameters.objOptimize = objOptimize;
    parameters.objOptimize.timetaken = toc(timeit);
    parameters = getLowestLoss(objOptimize, parameters);
end
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
    if parameters.getFeaturesFlag
        output(i,1) = featureExtraction(output(i,1),signal(i,1).samplingFreq,[{'selectedWindows'};{'burst'}]); % [1 * number of windows * number of sets]
    else
        output(i,1).features.maxValue = [];  % just a dummy value
    end
    
    % group features for classification
    output(i,1) = classificationGrouping(output(i,1),'maxValue',i,parameters.trainingRatio);
    
    % get a baseline as the third class
    if parameters.getBaselineFeatureFlag
        %     [dataValues, ~] = loadMultiLayerStruct(signal(i,1),parameters.overlappedWindow);
        output(i,1) = getBaselineFeature(output(i,1),signal(i,1).samplingFreq,signal(i,1).dataFiltered.values,parameters.baselineType,signal(i,1).dataTKEO.values);
    end
    
end
end