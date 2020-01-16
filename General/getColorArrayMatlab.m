function output = getColorArrayMatlab(varargin)
%GETCOLORARRAYMATLAB Get color code of Matlab lines.
% input:    the index of 
%   output = getColorArrayMatlab()

output = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840;0.502,0.502,0;0,0.502,0.502;0,0,1;0.4,0.4,0.6;1,0,1;1,0.8,1;0,1,0;0,1,1;1,0.6,0.8;0.8,1,0.8;0.8,0.6,1;1,1,0];

if nargin > 0
    numOutput = size(output,1);
    iColor = mod(varargin{1,1},numOutput);
    iColor(iColor == 0) = numOutput;
    output = output(iColor,:);
end

end

