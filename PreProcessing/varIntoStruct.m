function output = varIntoStruct(structure,varargin)
%VARINTOSTRUCT Insert variables into the strucutre.
%   Detailed explanation goes here

output = structure;

for i = 1:2:nargin-1
    if ismember(varargin{1,i},fieldnames(structure))
        output.(varargin{1,i}) = varargin{1,i+1};
    end
end

end

