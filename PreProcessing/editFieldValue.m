function data = editFieldValue(data, target, changes)
%EDITFIELDVALUE Edit all the field value found in data.
% intput:   data:   The main structure that contains the input 'target'
%           target: The target field to edit
%           changes:    The value that replaces the original value
%
%   [] = editFieldValue(data, target, changes)


editValue(data,target,changes);

end

function data = editValue(data,target,changes)
setGlobalx(data);
data = getGlobalx;

global x

if isstruct(x)
    numFields = length(fieldnames(x));
    
    if isfield(x,target)
        x.(target) = changes;
    else
        allFields = fieldnames(x);
        for i = 1:numFields
            try
                editValue(x.(allFields{i}),target,changes);
            catch
            end
        end
    end
end
end

function setGlobalx(value)
global x
x = value;
end

function r = getGlobalx
global x
r = x;
end

