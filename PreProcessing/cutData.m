function output = cutData(dataAll,dataRef,ref)
%cutData Cut the data that is equal to the reference
%   [] = cutData(dataAll,dataRef,ref,maxRef)

dataAll = checkSizeNTranspose(dataAll,2);

dataDiff = [-100000;diff(dataRef)];

locs = ismember(dataDiff,ref);

output = dataAll(locs,:);

end

