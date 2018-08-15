function output = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)
%GETMAXACCURACY Get the maximum accuracy of the classifier model
% input: data: .mat file that has been trained
%   accuracy, featureID, numTrainBurst, numTestBurst = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)

for i = 1:maxNumFeatureUsed
    numFeatureSetsTemp = length(data.varargin{1,1}.classificationOutput{1,1});
    % check the accuracy from all the utilized feature sets
    for j = 1:numFeatureSetsTemp
        accuracyMaxAll{i,1}(j,:) = max(horzcat(data.varargin{1,1}.classificationOutput{1,1}(j,1).accuracyAll{:,1}),[],1);
        
        for k = 1:numChannel
            accuracyPerc5All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{1,1}(j,1).accuracyAll{k,1},5);
            accuracyPerc95All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{1,1}(j,1).accuracyAll{k,1},95);
        end
    end
    
    accuracyPercRange{i,1} = accuracyPerc95All{i,1} - accuracyPerc5All{i,1};
    
    % find the maximum accuracy with the least percentile range
    for j = 1:numChannel
        accuracyMaxAllLocs{i,j} = find(accuracyMaxAll{i,1}(:,j) == max(accuracyMaxAll{i,1}(:,j)));

        % find the most suitable feature set to visualize
        accuracyPercRangeLeast{i,j} = accuracyPercRange{i,1}(accuracyMaxAllLocs{i,j},j); % all the range that corresponds to the accuracy that is maximum
        [~,locsTemp] = min(accuracyPercRangeLeast{i,j}); % get the locs of the minimum range in the list of all the ranges that correspond to the accuracy that is maximum
        accuracyLocs(i,j) = accuracyMaxAllLocs{i,j}(locsTemp); % get the feature ID thta has the maximum accuracy and teh minimum percentile range
        accuracyMax{1,1}(i,j) = accuracyMaxAll{i,1}(accuracyLocs(i,j),j);
    end
    
    for j = 1:numChannel
        % get feature ID
        featureID{1,1}{i,j} = data.varargin{1,1}.featureIndex{i,1}(accuracyLocs(i,j),:);
        
        % get average accuracy
        accuracyAve{1,1}(i,j) = mean(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1});
        
        % get percentile
        accuracyPerc5{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1},5);
        accuracyPerc95{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1},95);

    end
end

for j = 1:numChannel
    for k = 1:2 % class ID
        % get number of bursts
        numTrainBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(accuracyLocs(1,1)).trainingClass{j,1}==k));
        numTestBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(accuracyLocs(1,1)).testingClass{j,1}==k));
    end
end
    
    %% output
    output.accuracyMax = accuracyMax;
    output.featureID = featureID;
    output.numTrainBurst = numTrainBurst;
    output.numTestBurst = numTestBurst;
    output.accuracyAve = accuracyAve;
    output.accuracyPerc5 = accuracyPerc5;
    output.accuracyPerc95 = accuracyPerc95;
    
end

