function [output, outputName] = loadMultiLayerStruct(firstLayer,layers)
%loadMultiLayerStruct Generate output of the final layer contained in cell
%form. firstLayer should be in structure form and Layers sould be in cell
%form with layers inside
%   function output = loadMultiLayerStruct(firstLayer,Layers)

layers = cellstr(layers);
numLayers = length(layers);

output = firstLayer.(layers{1});
outputName = cell2mat(layers');

for i = 2:numLayers
    output = output.(layers{i});
end

end

