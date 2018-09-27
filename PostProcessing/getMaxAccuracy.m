function output = getMaxAccuracy(data,parameters)
%GETMAXACCURACY Get the maximum accuracy of the classifier model
% input: data: .mat file that has been trained
%   accuracy, featureID, numTrainBurst, numTestBurst = getMaxAccuracy(data,maxNumFeatureUsed,numChannel)

for i = 1:parameters.maxNumFeatureUsed
    numFeatureSetsTemp = length(data.varargin{1,1}.classificationOutput{1,1});
    numRepeat = size(data.varargin{1,1}.classificationOutput{1,1}(1,1).testingClass,1);
    % check the accuracy from all the utilized feature sets
    for j = 1:numFeatureSetsTemp
        accuracyMedianAll{i,1}(j,:) = median(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll,1);
        
        for k = 1:parameters.numChannel
            % 5 and 95 percentile
            accuracyPerc5All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll(:,k),parameters.lowerPercThresh);
            accuracyPerc95All{i,1}(j,k) = prctile(data.varargin{1,1}.classificationOutput{i,1}(j,1).accuracyAll(:,k),parameters.upperPercThresh);
        end
    end
    
    accuracyPercRange{i,1} = accuracyPerc95All{i,1} - accuracyPerc5All{i,1};
    
    % find the maximum accuracy with the least percentile range
    for j = 1:parameters.numChannel
        clear sensitivityTemp
        
        accuracyMedianAllLocs{i,j} = find(accuracyMedianAll{i,1}(:,j) == max(accuracyMedianAll{i,1}(:,j)));
        
        % find the most suitable feature set to visualize
        accuracyPercRangeLeast{i,j} = accuracyPercRange{i,1}(accuracyMedianAllLocs{i,j},j); % all the range that corresponds to the accuracy that is maximum
        [~,locsTemp] = min(accuracyPercRangeLeast{i,j}); % get the locs of the minimum range in the list of all the ranges that correspond to the accuracy that is maximum
        try
            accuracyLocs(i,j) = accuracyMedianAllLocs{i,j}(locsTemp); % get the feature ID thta has the maximum accuracy and teh minimum percentile range
            accuracyMedian{1,1}(i,j) = accuracyMedianAll{i,1}(accuracyLocs(i,j),j);
        catch
            accuracyLocs(i,j) = nan;
            accuracyMedian{1,1}(i,j) = nan;
        end
        
        % Sensitivity
        try
            for k = 1:numRepeat
                trueClassTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j),1).testingClass{k,j};
                predictClassTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j),1).predictClass{k,j};
                sensitivityOutputTemp = calculateAccuracy(predictClassTemp,trueClassTemp);
                sensitivityAll{1,1}{i,j}(k,:) = sensitivityOutputTemp.sensitivity;
            end
            sensitivityTemp = sensitivityAll{1,1}{i,j};
            sensitivityMedian{1,1}{i,j} = median(sensitivityTemp);
            sensitivityAve{1,1}{i,j} = mean(sensitivityTemp);
            sensitivityPerc5{1,1}{i,j} = prctile(sensitivityTemp,parameters.lowerPercThresh);
            sensitivityPerc95{1,1}{i,j} = prctile(sensitivityTemp,parameters.upperPercThresh);
        catch
            sensitivityAll{1,1}{i,j} = nan(1,parameters.numChannel);
            sensitivityMedian{1,1}{i,j} = nan(1,parameters.numChannel);
            sensitivityAve{1,1}{i,j} = nan(1,parameters.numChannel);
            sensitivityPerc5{1,1}{i,j} = nan(1,parameters.numChannel);
            sensitivityPerc95{1,1}{i,j} = nan(1,parameters.numChannel);
        end
        
        % get feature ID
        try
            featureID{1,1}{i,j} = data.varargin{1,1}.featureIndex{i,1}(accuracyLocs(i,j),:);
        catch
            featureID{1,1}{i,j} = nan;
        end
        
        % get average accuracy
        try
            accuracyAve{1,1}(i,j) = mean(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll(:,j));
        catch
            accuracyAve{1,1}(i,j) = nan;
        end
        
        % get percentile
        try
            accuracyPerc5{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll(:,j),parameters.lowerPercThresh);
            accuracyPerc95{1,1}(i,j) = prctile(data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).accuracyAll(:,j),parameters.upperPercThresh);
        catch
            accuracyPerc5{1,1}(i,j) = nan;
            accuracyPerc95{1,1}(i,j) = nan;
        end
        
        % class prediction
        try
            YTestTrueTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).testingClass{accuracyLocs(i,j),j};
            YTestPredictedTemp = data.varargin{1,1}.classificationOutput{i,1}(accuracyLocs(i,j)).predictClass{accuracyLocs(i,j),j};
            predictionVSKnownClass{1,1}{i,j} = horzcat(YTestTrueTemp,YTestPredictedTemp);
        catch
            predictionVSKnownClass{1,1}{i,j} = nan;
        end
    end
end

for j = 1:parameters.numChannel
    for k = 1:parameters.numClass % class ID
        
        % get number of bursts
        try
            numTrainBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(1).trainingClass{1,j}==k));
            numTestBurst{1,1}(k,j) = length(find(data.varargin{1,1}.classificationOutput{1,1}(1).testingClass{1,j}==k));
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
        catch
            % get number of bursts
            numTrainBurst{1,1}(k,j) = nan;
            numTestBurst{1,1}(k,j) = nan;
            
            % get some features
            % max value
            maxValue{1,1}(k,j) = nan;
            maxValueStde{1,1}(k,j) = nan;
            
            % mean value
            meanValue{1,1}(k,j) = nan;
            meanValueStde{1,1}(k,j) = nan;
            
            % burst length
            BL{1,1}(k,j) = nan;
            BLStde{1,1}(k,j) = nan;
            
            % duration between bursts
            durationBtwBursts{1,1}{k,j} = nan; % duration between bursts
        end
    end
end

%% output
output = makeStruct(accuracyMedian,featureID,numTrainBurst,numTestBurst,accuracyAve,...
    accuracyPerc5,accuracyPerc95,sensitivityAll,sensitivityMedian,sensitivityAve,...
    sensitivityPerc5,sensitivityPerc95,maxValue,maxValueStde,BL,BLStde,meanValue,...
    meanValueStde,durationBtwBursts,predictionVSKnownClass,accuracyLocs);

end

