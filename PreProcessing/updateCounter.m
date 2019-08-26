function [repCount, changeIndex] = updateCounter(repCount, changeIndex, deltaLoss, parameters)
%UPDATECOUNTER Used in dataClassificationPreparation
%   [repCount, changeIndex] = updateCounter(repCount, changeIndex, deltaLoss)

if repCount == 10 || abs(deltaLoss) < parameters.deltaLossLimit
    repCount = 1;
    
    if changeIndex(1,2) == 4
        if changeIndex(1,1) == 3
            changeIndex(1,1) = 1;
        else
            changeIndex(1,1) = changeIndex(1,1) + 1;
        end
        changeIndex(1,2) = 1;
    else
        changeIndex(1,2) = changeIndex(1,2) + 1;
    end
else
    repCount = repCount + 1;
end
end
