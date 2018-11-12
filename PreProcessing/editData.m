function output = editData(dataAll,dataRef,ref,type)
%EDITDATA Cut the data that is not equal to the reference, assumed that the
%baseline is equal to zeros and the extra number that needs to be included
%is saved in input 'ref'
% 
% input:    dataAll:    data-to-be-eidted
%           dataRef:    data for checking the ref
%           ref:        only get the data that has the correct ref
%           type:       1 to cut only, 2 to pad zeros on messy data, 
%                       3 to pad zeros on cut data
% 
%   [] = editData(dataAll,dataRef,ref,maxRef)

dataAll = checkSizeNTranspose(dataAll,2);

repNum = 9; % number of nearby elements for checking if the counter is legit one

dataRefLength = length(dataRef);

numExtend = repNum-1;

dataTemp = zeros(numExtend+dataRefLength,repNum);

for i = 1:repNum
    dataTemp(i:(dataRefLength+numExtend)-(repNum-i),i) = dataRef;
end

dataTemp = sum(dataTemp,2);

locs = ismember(dataTemp,ref);
locs = locs(numExtend:end-(numExtend-1));

switch type
    case 1
        output = dataAll(locs,:);
    case 2
        dataAll(~locs,:) = 0;
        output = dataAll;
    case 3
        output = padZero(dataAll,dataRef,0,0);
end

end

