function [trueClass,predictClass] = getTrueNPredictClass(dataFiltered,classifierMdl,burstStartLocs,burstEndLocs,parameters)
%GETTRUENPREDICTCLASS Summary of this function goes here
%   Detailed explanation goes here

iters = length(dataFiltered);

for i = 1:iters
    dataSize = length(dataFiltered{i,1});
    numBursts = length(burstStartLocs{i,1});
    
    movingWindowArray = parameters.movingWindowSize : parameters.overlapWindowSize : dataSize;
    numWindow = length(movingWindowArray);
    trueClass{i,1} = zeros(numWindow,1);
    predictClass{i,1} = zeros(numWindow,1);

    % True Class
    for j = 1:numBursts
        locsTemp = movingWindowArray > burstStartLocs{i,1}(j,1) & movingWindowArray < burstEndLocs{i,1}(j,1);
        trueClass{i,1}(locsTemp) = 1;
    end
    
    % Classification
    for j = 1:numWindow
        windowFeatureTemp = dataFiltered{i,1}(movingWindowArray(1,j)-parameters.movingWindowSize+1 : movingWindowArray(1,j));
        featureTemp = featureExtraction(windowFeatureTemp,parameters.samplingFreq);
        featureTemp = featureTemp.(parameters.featureNamesAll{parameters.featureIndex});
        predictClass{i,1}(j,1) = predict(classifierMdl{i,1},featureTemp);
        if predictClass{i,1}(j,1) == 2
            predictClass{i,1}(j,1) = 0;
        end
    end
end



end

