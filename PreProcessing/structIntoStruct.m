function originalStruct = structIntoStruct(originalStruct, newStruct)
%STRUCTINTOSTRUCT Insert the field of newStruct into originalStruct if it
%appears in both stuctures.
%   originalStruct = structIntoStruct(originalStruct, newStruct)

fieldOrig = fieldnames(originalStruct);
fieldNew = fieldnames(newStruct);

numFieldNew = length(fieldNew);

for i = 1:numFieldNew
    if ismember(fieldNew{i,1}, fieldOrig)
        originalStruct.(fieldNew{i,1}) = newStruct.(fieldNew{i,1});
    end
end


end

