function [] = errorShow(input, inputName, requiredClass)
%errorShow Show an error that input is not in a correct type
%   function [] = errorShow(name, type)

inputClass = class(input);

if ~isequal(inputClass, requiredClass)
    error([inputName, ' must be a class of ', requiredClass])
end

end

