function [trueClass,predictClass] = getTrueNPredictClass(dataTKEO,dataFiltered,threshold,classifierMdl,parameters)
%GETTRUENPREDICTCLASS Summary of this function goes here
%   Detailed explanation goes here

iters = length(dataTKEO);

startPartLength = parameters.movingWindowSize - parameters.endPartLength;

for i = 1:iters
    dataSize = length(dataTKEO{i,1});
    for j = 1 : parameters.overlapWindowSize : dataSize - parameters.movingWindowSize
        % Active window determination
        windowThreshTemp = dataTKEO{i,1}(j : j+parameters.movingWindowSize-1);
        windowEndPartTemp = windowThreshTemp(end-parameters.endPartLength+1:end);
        windowStartPartTemp = windowThreshTemp(1:end-parameters.endPartLength);
        if all(windowEndPartTemp > threshold(i,1))
            trueClass(j,i) = 1;
        elseif all(windowEndPartTemp < threshold(i,1))
            trueClass(j,i) = 0;
        else % check the starting part, if half of it exceeds threshold, then this window is active state
            checkStartPart = windowStartPartTemp > threshold(i,1);
            trueClass(j,i) = sum(checkStartPart) >= startPartLength/2;
        end
        
        % Classification
        windowFeatureTemp = dataFiltered{i,1}(j : j+parameters.movingWindowSize-1);
        featureTemp = featureExtraction(windowFeatureTemp,parameters.samplingFreq);
        featureTemp = featureTemp.(parameters.featureNamesAll{parameters.featureIndex});
        predictClass(j,i) = predict(classifierMdl{i,1},featureTemp);
        if predictClass(j,i) == 2
            predictClass(j,i) = 0;
        end
    end
end



end

