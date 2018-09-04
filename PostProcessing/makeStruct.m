function output = makeStruct(varargin)
%MAKESTRUCT Stored the varargin as a field into a structure 'output' with the same name
% 
%   output = makeStruct(varargin)

for i = 1:nargin
    nameTemp = inputname(i);
    output.(nameTemp) = varargin{1,i};
end

end

