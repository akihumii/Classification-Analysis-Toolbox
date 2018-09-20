function output = mat2confusionMat(data)
%MAT2CONFUSIONMAT Convert a matrix into the format for plotting confusion
%matrix with N-M matrix, where N is the number of class and M is the number
%of observation. 
% 
%   output = mat2confusionMat(data)

classArray = unique(data);
numElementInEachClass = histc(data,classArray);

numClass = length(classArray);

output = zeros(numClass,length(data));

numClassTemp = [1;numElementInEachClass];

for i = 1:numClass
    output(i, numClassTemp(i,1):numClassTemp(i+1,1)) = ones(1,numElementInEachClass(i,1));
    if i ~= numClass
        numClassTemp(i+1:end,1) = numClassTemp(i+1:end,1) + numClassTemp(i:end-i,1);
    end
end

end

