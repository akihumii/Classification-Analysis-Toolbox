function [parameters, change, changeIndex] = editTKEOParameters(lossOrig, deltaLoss, parameters, change, changeIndex)
%EDITTKEOPARAMETERS Used in dataClassfiicationPreparation
%   [parameters, change, changeIndex] = editTKEOParameters(clfp, lossOrig, deltaLoss, parameters, change, changeIndex)

updateValue = sign(deltaLoss) * sign(change(changeIndex(1,1), changeIndex(1,2))) * ...
    (floor(parameters.learningRate(changeIndex(1,1)) * ...
    sigmf(abs(deltaLoss/lossOrig) * 100, [0.1, 50])) + 1);
if sign(updateValue) ~= sign(change(changeIndex(1,1), changeIndex(1,2)))
    updateValue = updateValue + sign(updateValue) * abs(change(changeIndex(1,1), changeIndex(1,2)));
end

change(changeIndex(1,1), changeIndex(1,2)) = updateValue;
switch changeIndex(1,1)
    case 1
        parameters.TKEOStartConsecutivePoints(1, changeIndex(1,2)) = ...
            parameters.TKEOStartConsecutivePoints(1, changeIndex(1,2)) + updateValue;
        fprintf('channel %d | TKEO starting: %d\n', changeIndex(1,2), parameters.TKEOStartConsecutivePoints(1, changeIndex(1,2)));
    case 2
        parameters.TKEOEndConsecutivePoints(1, changeIndex(1,2)) = ...
            parameters.TKEOEndConsecutivePoints(1, changeIndex(1,2)) + updateValue;
        fprintf('channel %d | TKEO end: %d\n', changeIndex(1,2), parameters.TKEOEndConsecutivePoints(1, changeIndex(1,2)));
    case 3
        parameters.threshStdMult(1, changeIndex(1,2)) = ...
            parameters.threshStdMult(1, changeIndex(1,2)) + updateValue;
        fprintf('channel %d | thresh mult: %d\n', changeIndex(1,2), parameters.threshStdMult(1, changeIndex(1,2)));
end
end
