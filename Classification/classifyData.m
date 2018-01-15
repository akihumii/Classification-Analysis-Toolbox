function predictedClass = classifyData(features,parameters)
%classifyData Classify a set of data with parameters
%   Detailed explanation goes here

numClass = size(parameters,1);

classTemp = zeros(0,1); % to check against all the parameters

for i = 2:numClass
    constant = parameters(1,i).const;
    linear = parameters(1,i).linear;
    value = constant + features * linear;
    
    if value > 0
        classTemp = [classTemp; parameters(1,i).name1];
    else
        classTemp = [classTemp; parameters(1,i).name2];
    end
end

predictedClass = mode(classTemp);

end

