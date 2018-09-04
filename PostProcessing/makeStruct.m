function structure = makeStruct(varargin)
%MAKESTRUCT Stored the varargin as a field into a structure 'output' with the same name
% 
%   output = makeStruct(varargin)

for i = 1:nargin
    structure.(inputname(i)) = varargin{1,i};
end

end

