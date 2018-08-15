function [accuracy, featureID, numTrainBurst, numTestBurst] = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)
%GETMAXACCURACY Get the maximum accuracy of the classifier model
% input: data: .mat file that has been trained
%   accuracy, featureID, numTrainBurst, numTestBurst = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)

for i = 1:maxNumFeatureUsed
    % get accuracy
    [accuracy(i,:), accuracyLocs(i,:)] = max(data.varargin{1,1}.accuracy{i,1},[],1);
    
    for j = 1:numChannel
        % get feature ID
        featureID{i,j} = data.varargin{1,1}.featureIndex{i,1}(accuracyLocs(i,j),:);
    end
end

% get number of bursts
for j = 1:numChannel
    for k = 1:2 % class ID
        numTrainBurst(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(accuracyLocs(1,1)).trainingClass{j,1}==k));
        numTestBurst(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(accuracyLocs(1,1)).testingClass{j,1}==k));
    end
end

end

