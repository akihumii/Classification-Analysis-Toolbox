function output = rearrangeSensitivity(data)
%REARRANGESENSITIVITY Rearrange the sensitivity in the outputIndividual
%produced from checkAccuracy.
% 
%   output = rearrangeSensitivity(data)

numChannel = length(data);
numFeatureDim = size(data{1,1},2);

for i = 1:numChannel
    for j = 1:numFeatureDim
        dataTemp = vertcat(data{i,1}{:,j});
        output{i,j} = dataTemp;
    end
end


end

