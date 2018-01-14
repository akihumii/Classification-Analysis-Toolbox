function output = discreteClassification(dataTKEO,dataFiltered,samplingFreq,windowSize,windowSkipSize,detectionInfo,featureIndex,classifierParameters,correctClass)
%discreteClassification Run the entire signal and classfify the windows
%with same sizes and separted with windowSkipSize
%   predictedClass = discreteClassification(dataTKEO,dataFiltered,samplingFreq,windowSize,windowSkipSize,detectionInfo,featureIndex,classifierParameters,correctClass)

[rowData, colData] = size(dataTKEO);

windowSize = windowSize * samplingFreq; % convert from seconds into sample points
windowSkipSize = windowSkipSize * samplingFreq; % convert from seconds into sample points

burstEndValue = 0;

for i = 1:colData % channels
    count = 1;
    features{i,1} = zeros(0,1);
    predictedClass{i,1} = zeros(0,1);
    startingPointAll{i,1} = zeros(0,1);
    endPointAll{i,1} = zeros(0,1);
    
    startingPoint = windowSkipSize * (count-1);
    
    while (1+ windowSize + startingPoint) <= rowData
        dataTKEOTemp = dataTKEO(1+windowSkipSize * (count-1) : 1+startingPoint + windowSize,i);
        outputTemp = detectSpikes(dataTKEOTemp,repmat(windowSize,1,2),detectionInfo.threshold(i),1,detectionInfo.detectionMethod,detectionInfo.threshStdMult,detectionInfo.TKEOStartConsecutivePoints,detectionInfo.TKEOEndConsecutivePoints);
        
        if length(outputTemp.spikePeaksValue)==1 && ~isnan(outputTemp.spikePeaksValue) && burstEndValue~=outputTemp.burstEndValue % check if it's an empty array / nan value / same burst
            startingPointAll{i,1} = [startingPointAll{i,1};startingPoint+outputTemp.spikeLocs]; % store the starting piont of the detected bursts
            endPointAll{i,1} = [endPointAll{i,1};startingPoint+outputTemp.burstEndLocs]; % store the end point of the detected bursts
            featuresTemp = featureExtraction(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i),samplingFreq); % extract features from the detected bursts that exceeds the threshold
            featuresTemp = transpose(struct2cell(featuresTemp));
            features{i,1} = [features{i,1};cell2mat(featuresTemp(featureIndex))];
            
            predictedClass{i,1} = [predictedClass{i,1};classifyData(features{i,1}(end,:),classifierParameters{i,1})];
            
            burstEndValue = outputTemp.burstEndValue;
            
            % plotFig(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i));
        end
        count = count + 1;
        startingPoint = windowSkipSize * (count-1);
        
    end
    correctClassTemp = repmat(correctClass,length(predictedClass{i,1}),1);
    accuracy(i,1) = calculateAccuracy(predictedClass{i,1}, correctClassTemp);
end

startingPointAll = cell2nanMat(startingPointAll);
endPointAll = cell2nanMat(endPointAll);

output.features = features;
output.predictedClass = predictedClass;
output.accuracy = accuracy;
output.startPointAll = startingPointAll;
output.endPointAll = endPointAll;

end

