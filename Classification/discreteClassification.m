function [] = discreteClassification(dataTKEO,dataFiltered,samplingFreq,windowSize,windowSkipSize,detectionInfo,featureIndex,classifierParameters,correctClass)
%discreteClassification Run the entire signal and classfify the windows
%with same sizes and separted with windowSkipSize
%   Detailed explanation goes here

[rowData, colData] = size(dataTKEO);
count = 1;

windowSize = windowSize * samplingFreq; % convert from seconds into sample points
windowSkipSize = windowSkipSize * samplingFreq; % convert from seconds into sample points

burstEndValue = 0;

for i = 1:colData % channels
    
    startingPoint = windowSkipSize * (count-1);
    
    while (1+ windowSize + startingPoint) <= rowData        
        outputTemp = detectSpikes(...
            dataTKEO(1+windowSkipSize * (count-1) : 1+startingPoint + windowSize,i),...
            repmat(windowSize,1,2),detectionInfo.threshold(i),1,detectionInfo.detectionMethod,detectionInfo.threshStdMult,detectionInfo.TKEOStartConsecutivePoints,detectionInfo.TKEOEndConsecutivePoints);
        
        if length(outputTemp.spikePeaksValue)==1 && ~isnan(outputTemp.spikePeaksValue) && burstEndValue~=outputTemp.burstEndValue % check if it's an empty array / nan value / same burst
            featuresTemp = featureExtraction(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i),samplingFreq); % extract features from the detected bursts that exceeds the threshold
            featuresTemp = struct2cell(featuresTemp);
            features = cell2mat(featuresTemp(featureIndex));
            
            predictedClass = classifyData(features',classifierParameters);
            
            burstEndValue = outputTemp.burstEndValue;
            
%             plotFig(dataFiltered(startingPoint+(outputTemp.spikeLocs:outputTemp.burstEndLocs),i));
        end
        count = count + 1;
        startingPoint = windowSkipSize * (count-1);
        
        
    end
    
end

end

