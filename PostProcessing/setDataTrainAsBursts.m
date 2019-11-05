function dataBursts = setDataTrainAsBursts(outputBurstDetection, data)
%SETDATATRAINASBURSTS Gather the bursts into one matrix with respect to the
%locations specified in outputBurstDection, which is generated by the 
%function detectSpike
%   dataBursts = setDataTrainAsBursts(outputBurstDetection, data)
numBursts = numel(outputBurstDetection.spikeLocs);
data = reshape(data, [], size(data,3));  % transform it into an 1D array
bursts = cell(numBursts, 1);
for i = 1:numBursts
    locsTemp = outputBurstDetection.spikeLocs(i,1):...
        outputBurstDetection.burstEndLocs(i,1);
    bursts{i,1} = data(locsTemp, :);
end
dataBursts = cell2nanMat(bursts);
if size(dataBursts, 3) ~= 1
    dataBursts = permute(dataBursts, [1,3,2]);  % [dataPoints x chunk x channel]
end
end