function output = varIntoStruct(structure,varargin)
%VARINTOSTRUCT Insert variables into the strucutre.
%   output = varIntoStruct(structure,varargin)

output = structure;

if ~isempty(varargin{1,1})
    for i = 1:2:nargin-1
        if ismember(varargin{1,1}{1,i},fieldnames(structure))
            output.(varargin{1,1}{1,i}) = varargin{1,1}{1,i+1};
        end
    end
end

end

