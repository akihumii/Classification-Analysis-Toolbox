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
    
    startingPoint = windowSkipSize * (count-1);
    
    while (1+ windowSize + startingPoint) <= rowData        
        outputTemp = detectSpikes(...
            dataTKEO(1+windowSkipSize * (count-1) : 1+startingPoint + windowSize,i),...
            repmat(windowSize,1,2),detectionInfo.threshold(i),1,detectionInfo.detectionMethod,detectionInfo.threshStdMult,detectionInfo.TKEOStartConsecutivePoints,detectionInfo.TKEOEndConsecutivePoints);
        
        if length(outputTemp.spikePeaksValue)==1 && ~isnan(outputTemp.spikePeaksValue) && burstEndValue~=outputTemp.burstEndValue % check if it's an empty array / nan value / same burst
            featuresTemp = featureExtraction(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i),samplingFreq); % extract features from the detected bursts that exceeds the threshold
            featuresTemp = transpose(struct2cell(featuresTemp));
            features{i,1} = [features{i,1};cell2mat(featuresTemp(featureIndex))];
            
            predictedClass{i,1} = [predictedClass{i,1};classifyData(features{i,1}(end,:),classifierParameters{1,i})];
            
            burstEndValue = outputTemp.burstEndValue;
            
%             plotFig(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i));
        end
        count = count + 1;
        startingPoint = windowSkipSize * (count-1);
        
        
    end
    correctClassTemp = repmat(correctClass,length(predictedClass{i,1}),1);
    accuracy(i,1) = calculateAccuracy(predictedClass{i,1}, correctClassTemp);
end

output.features = features;
output.predictedClass = predictedClass;
output.accuracy = accuracy;

end

