function [values, change] = changeValues(values, maxNum)
%CHANGEVALUES Used in dataClassificationPreparation.
%   [values, change] = changeValues(values, maxNum)
change = floor(maxNum/2 * (rand()-0.5));
change = repmat(change, size(values));
values = values + change;
end
