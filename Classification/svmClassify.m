function output = svmClassify(grouping)
%svmClassify Generate SVM classifier parameters
%   output = svmClassify(grouping)
% Fields contained in svmStruct:
% SupportVectors — support vectors x new axis
% Alpha — Vector of weights for the support vectors. Sign of values represent the group they belong to 
% Bias — Intercept of the hyperplane that separates the two groups in the normalized data space


for i = 1:length(grouping.testing.reconstructed)
    svmStruct{i,1} = ...
        svmtrain(grouping.training.reconstructed{i,1},...
        grouping.trainingClass{i,1});
    
    svmStruct{i}.Alpha = sign(svmStruct{i}.Alpha); % assign into group of either positive or negative
    svmStruct{i}.Alpha(svmStruct{i}.Alpha==-1) = 0; % assign into group of either one or zero.
    
    accuracy{i} = calculateAccuracy(grouping,svmStruct{i}.Alpha,i);
end

output.svmStruct = svmStruct;
output.accuracy = accuracy;
output.channelPair = grouping.channelPair;
output.grouping = grouping;
end

