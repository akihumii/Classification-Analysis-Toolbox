function output = mat2confusionMat(data)
%MAT2CONFUSIONMAT Convert a matrix into the format for plotting confusion
%matrix with N-M matrix, where N is the number of class and M is the number
%of observation. 
% 
%   output = mat2confusionMat(data)

classArray = unique(data);

numClass = length(classArray);

output = zeros(numClass,length(data));


for i = 1:numClass
    output(i,data==classArray(i)) = 1;
end

end

