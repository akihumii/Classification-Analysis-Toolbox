function output = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)
%GETMAXACCURACY Get the maximum accuracy of the classifier model
% input: data: .mat file that has been trained
%   accuracy, featureID, numTrainBurst, numTestBurst = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)

for i = 1:maxNumFeatureUsed
    numFeatureSetsTemp = length(data.varargin{1,1}.classificationOutput{1,1});
    % check the accuracy from all the utilized feature sets
    for j = 1:numFeatureSetsTemp
        accuracyMedianAll{i,1}(j,:) = median(horzcat(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll{:,1}),1);
        
        for k = 1:numChannel
            accuracyPerc5All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll{k,1},5);
            accuracyPerc95All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll{k,1},95);
        end
    end
    
    accuracyPercRange{i,1} = accuracyPerc95All{i,1} - accuracyPerc5All{i,1};
    
    % find the maximum accuracy with the least percentile range
    for j = 1:numChannel
        accuracyMedianAllLocs{i,j} = find(accuracyMedianAll{i,1}(:,j) == max(accuracyMedianAll{i,1}(:,j)));

        % find the most suitable feature set to visualize
        accuracyPercRangeLeast{i,j} = accuracyPercRange{i,1}(accuracyMedianAllLocs{i,j},j); % all the range that corresponds to the accuracy that is maximum
        [~,locsTemp] = min(accuracyPercRangeLeast{i,j}); % get the locs of the minimum range in the list of all the ranges that correspond to the accuracy that is maximum
        accuracyLocs(i,j) = accuracyMedianAllLocs{i,j}(locsTemp); % get the feature ID thta has the maximum accuracy and teh minimum percentile range
        accuracyMedian{1,1}(i,j) = accuracyMedianAll{i,1}(accuracyLocs(i,j),j);
    end
    
    for j = 1:numChannel
        % get feature ID
        featureID{1,1}{i,j} = data.varargin{1,1}.featureIndex{i,1}(accuracyLocs(i,j),:);
        
        % get average accuracy
        accuracyAve{1,1}(i,j) = mean(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1});
        
        % get percentile
        accuracyPerc5{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1},5);
        accuracyPerc95{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll{j,1},95);
        
        % class prediction
        YTestTrueTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).testingClass{j,1};
        YTestPredictedTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).class{j,1};
        predictionVSKnownClass{1,1}{i,j} = horzcat(YTestTrueTemp,YTestPredictedTemp);
    end
end

for j = 1:numChannel
    for k = 1:2 % class ID
        % get number of bursts
        numTrainBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).trainingClass{j,1}==k));
        numTestBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).testingClass{j,1}==k));
        
        % get some features
        % max value
        maxValueIndex = 1;
        maxValue{1,1}(k,j) = mean(data.varargin{1,2}.featuresAll{k,maxValueIndex,j});
        maxValueStde{1,1}(k,j) = data.varargin{1,2}.featureStde(maxValueIndex,k,j);
        
        % mean value
        meanValueIndex = 5;
        meanValue{1,1}(k,j) = mean(data.varargin{1,2}.featuresAll{k,meanValueIndex,j});
        meanValueStde{1,1}(k,j) = data.varargin{1,2}.featureStde(meanValueIndex,k,j);

        % burst length
        BLIndex = 3;
        BL{1,1}(k,j) = mean(data.varargin{1,2}.featuresAll{k,BLIndex,j});
        BLStde{1,1}(k,j) = data.varargin{1,2}.featureStde(BLIndex,k,j);
        
        % duration between bursts
        spikeLocsTemp = data.varargin{1,3}(k,1).detectionInfo.spikeLocs(:,j); % get the corresponding burst onset location
        spikeLocsTemp = spikeLocsTemp(~isnan(spikeLocsTemp)); % ommit the NaN
        spikeLocsTemp = [spikeLocsTemp;spikeLocsTemp(end)]; % repeat the last location one more time to compensate the one missing location after doing the differential
        durationBtwBursts{1,1}{k,j} = diff(spikeLocsTemp); % duration between bursts
    end
end
    
    %% output
    output.accuracyMedian = accuracyMedian;
    output.featureID = featureID;
    output.numTrainBurst = numTrainBurst;
    output.numTestBurst = numTestBurst;
    output.accuracyAve = accuracyAve;
    output.accuracyPerc5 = accuracyPerc5;
    output.accuracyPerc95 = accuracyPerc95;
    output.maxValue = maxValue;
    output.maxValueStde = maxValueStde;
    output.BL = BL;
    output.BLStde = BLStde;
    output.meanValue = meanValue;
    output.meanValueStde = meanValueStde;
    output.durationBtwBursts = durationBtwBursts;
    output.predictionVSKnownClass = predictionVSKnownClass;
    output.accuracyLocs = accuracyLocs;
    
end

