function values = multiplyValues(values)
%MULTIPLYVALUES Used in dataClassificationPreparation
%   values = multiplyValues(values)
if ~any(size(values) ~= 1)
    values = repmat(values, 1, 4);
end
end