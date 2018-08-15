function [] = saveClassificationVariables()
%SAVECLASSIFICATIONVARIABLES Extract the features and save it in a new mat file.
%   Detailed explanation goes here

allMat = dir('*.mat');
numMat = length(allMat);

for i = 1:numMat
    summaryMat(i,1).name = allMat.name;
    matTemp = load(allMat(i,1).name);
    summaryMat(i,1).accuracy = matTemp.varargin{1,1}.accuracyMax;
    summaryMat(i,1).maxFeatureCombo = matTemp.varargin{1,1}.maxFeatureCombo;
    
    name{i,1} = summaryMat(i,1).name;
    oneDimTA(i,1) = summaryMat(i,1).accuracy(1,1);
    oneDimGC(i,1) = summaryMat(i,1).accuracy(1,2);
    twoDimTA(i,1) = summaryMat(i,1).accuracy(2,1);
    twoDimGC(i,1) = summaryMat(i,1).accuracy(2,2);
    
    oneDimFeature(i,1) = summaryMat(i,1).maxFeatureCombo{1,1};
    twoDimFeature(i,:) = summaryMat(i,1).maxFeatureCombo{2,1};
end

summaryTable = table(name,oneDimTA,oneDimGC,twoDimTA,twoDimGC,oneDimFeature,twoDimFeature);

writetable(summaryTable,['summaryTable',time2string,'.xlsx']);

end

