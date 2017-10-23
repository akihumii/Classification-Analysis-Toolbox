function output = dataClassificationPreparation(signal, iter)
%dataClassification Detect windows, extract features, execute
%classification
%   output = dataClassification()

output(iter,1) = classClassificationPreparation; % pre-allocation

for i = 1:iter
output(i,1) = classClassificationPreparation(signal(i,1).file,signal(i,1).path,[0.005,0.02]);
output(i,1) = detectSpikes(output(i,1), signal(i,1), 'dataRaw', 'threshold');
output(i,1) = classificationWindowSelection(output(i,1), signal(i,1), 'dataFiltered');
output(i,1) = featureExtraction(output(i,1),[{'selectedWindows'};{'windowFollowing'}]); % [1 * number of windows * number of sets]
output(i,1) = classificationGrouping(output(i,1),'maxValue',i);
end

end

