function [trueClass,predictClass] = getTrueNPredictClass(dataTKEO,dataFiltered,threshold,classifierMdl,parameters)
%GETTRUENPREDICTCLASS Summary of this function goes here
%   Detailed explanation goes here

iters = length(dataTKEO);

for i = 1:iters
    dataSize = length(dataTKEO{i,1});
    for j = 1 : parameters.overlapWindowSize : dataSize - parameters.movingWindowSize
        % Active window determination
        windowThreshTemp = dataTKEO{i,1}(j : j+parameters.movingWindowSize-1);
        
        trueClass(j,i) = sum(windowThreshTemp > threshold(i,1)) > parameters.movingWindowSize/2;
        
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

