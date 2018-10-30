function output = classification(trials,featureIndex,trainingRatio,classifierTitle,parameters)
%classification Perform lda classification with trials that are in cells.
% The structure is like: [channel * feature * class]
%
%   output = classification(trials,featureIndex,trainingRatio,classifierTitle,parameters.classificationRepetition)

[numClasses,~,numChannels] = size(trials);
if parameters.mergeChannelFeatures
    [d1,d2,d3] = size(trials);
    trialsTemp = cell(d1,d2);
    for i = 1:numChannels
        for j = 1:d1
            for k = 1:d2
                trialsTemp{j,k,1} = cat(2, trialsTemp{j,k,1}, trials{j,k,i});
            end
        end
    end
    
    trials = repmat(trialsTemp,1,1,numChannels);
end

numSelectedFeatures = length(featureIndex);
accuracyAll = nan(parameters.classificationRepetition,numChannels);

for i = 1:numChannels
    accuracyHighest(:,i) = zeros(2,1); % initialize accuracy
    try
        for r = 1:parameters.classificationRepetition
            
            groupedFeature = combineFeatureWithoutNan(trials(:,featureIndex(1,:),i),trainingRatio,numClasses);
            
            switch parameters.classifierName
                case 'svm'
                    svmClassificationOutput = svmClassification(groupedFeature.training,groupedFeature.trainingClass,groupedFeature.testing);
                    accuracyTemp = calculateAccuracy(svmClassificationOutput.predictClass,groupedFeature.testingClass);
                case 'lda'
                    [classTemp,errorTemp,posteriorTemp,logPTemp,coefficientTemp] = ... % run the classification
                        classify(groupedFeature.testing,groupedFeature.training,groupedFeature.trainingClass);
                    accuracyTemp = calculateAccuracy(classTemp,groupedFeature.testingClass);
                case 'knn'
                    knnClassificationOutput = knnClassification(groupedFeature.training,groupedFeature.trainingClass,groupedFeature.testing);
                    accuracyTemp = calculateAccuracy(knnClassificationOutput.predictClass,groupedFeature.testingClass);
                otherwise
                    error('Invalid classifier name...')
            end
            
            accuracyAll(r,i) = accuracyTemp.accuracy;
            
            %         if accuracyTemp.accuracy > accuracyHighest(1,i) % record the result from the classifier that has the highest performance
            accuracyHighest(:,i) = accuracyTemp.accuracy;
            switch parameters.classifierName
                case 'svm'
                    %                     class{i,1} = svmClassificationOutput.predictClass;
                    predictClass{r,i} = svmClassificationOutput.predictClass;
                    if accuracyTemp.accuracy >= accuracyHighest(1,i)
                        Mdl{i,1} = svmClassificationOutput.Mdl;
                    end
                case 'lda'
                    %                     class{i,1} = classTemp;
                    predictClass{r,i} = classTemp;
                    if accuracyTemp.accuracy >= accuracyHighest(1,i)
                        Mdl{i,1} = coefficientTemp;
                    end
                case 'knn'
                    %                     class{i,1} = knnClassificationOutput.predictClass;
                    predictClass{r,i} = knnClassificationOutput.predictClass;
                    if accuracyTemp.accuracy >= accuracyHighest(1,i)
                        Mdl{i,1} = knnClassificationOutput.Mdl;
                    end
            end
            %         end
            %             error{i,1} = errorTemp;
            %             posterior{i,1} = posteriorTemp;
            %             logP{i,1} = logPTemp;
            %             coefficient{i,1} = coefficientTemp;
            training{r,i} = groupedFeature.training;
            testing{r,i} = groupedFeature.testing;
            trainingClass{r,i} = groupedFeature.trainingClass;
            testingClass{r,i} = groupedFeature.testingClass;
            %         end
            
            % plot confusion matrix
            %         plotConfusionMat(svmClassificationOutput.predictClass,groupedFeature.testingClass)
            %         title(['Fature ',checkMatNAddStr(featureIndex,','),' Channel ',num2str(i)])
        end
        accuracy(:,i) = mean(accuracyAll(:,i),2);
    catch
        Mdl{i,1} = nan;
        accuracy(:,i) = nan;
        accuracyHighest(1,i) = nan;
        training{1,i} = nan;
        testing{1,i} = nan;
        trainingClass{1,i} = nan;
        testingClass{1,i} = nan;
        predictClass{1,i} = nan;
        
    end
end


%% Output
output = makeStruct(...
    classifierTitle,...
    Mdl,...
    accuracy,...
    accuracyAll,...
    accuracyHighest,...
    training,...
    testing,...
    trainingClass,...
    testingClass,...
    predictClass);
end


