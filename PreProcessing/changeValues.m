function [values, change] = changeValues(values, maxNum)
%CHANGEVALUES Used in dataClassificationPreparation.
%   [values, change] = changeValues(values, maxNum)
randNum = (rand()-0.5);
change = ceil(maxNum/2 * abs(randNum));
change = sign(randNum) * change;
change = repmat(change, size(values));
values = values + change;
end
