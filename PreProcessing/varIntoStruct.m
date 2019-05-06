function output = varIntoStruct(structure,varargin)
%VARINTOSTRUCT Insert variables into the strucutre.
%   output = varIntoStruct(structure,varargin)

output = structure;

if ~isempty(varargin{1,1})
    for i = 1:2:length(varargin{1,1})-1
        if ismember(varargin{1,1}{1,i},fieldnames(structure))
            fieldName = varargin{1,1}{1,i};
            fieldValue = varargin{1,1}{1,i+1};
            output.(fieldName) = fieldValue;
        end
    end
end

end

