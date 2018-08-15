function predictedClass = classifyData(features,parameters)
%classifyData Classify a set of data with parameters
%   Detailed explanation goes here

[numRow,numCol] = size(parameters);

classTemp = zeros(0,1); % to check against all the parameters

for i = 1:numRow
    for j = 1:numCol
        if ~isempty(parameters(i,j).name1)
            constant = parameters(i,j).const;
            linear = parameters(i,j).linear;
            value = constant + features * linear;
            
            if value > 0
                classTemp = [classTemp; parameters(i,j).name1];
            else
                classTemp = [classTemp; parameters(i,j).name2];
            end
        end
    end
end

predictedClass = mode(classTemp);

end

