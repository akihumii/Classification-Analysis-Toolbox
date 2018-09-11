function output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat,classifierName)
%classification Perform lda classification with trials that are in cells.
% The structure is like: [channel * feature * class]
% 
%   output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat)
 
[numClasses,~,numChannels] = size(trials);
numSelectedFeatures = length(featureIndex);
 
for i = 1:numChannels
    accuracyHighest(:,i) = zeros(2,1); % initialize accuracy
    try
    for r = 1:numRepeat

        groupedFeature = combineFeatureWithoutNan(trials(:,featureIndex(1,:),i),trainingRatio,numClasses);

        switch classifierName
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

        accuracyAll{i,1}(:,r) = accuracyTemp.accuracy;
        
%         if accuracyTemp.accuracy > accuracyHighest(1,i) % record the result from the classifier that has the highest performance
            accuracyHighest(:,i) = accuracyTemp.accuracy;
            switch classifierName
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
    accuracy(:,i) = mean(accuracyAll{i,1},2);
            catch
    Mdl{i,1} = nan;
    accuracy(:,i) = nan;
    accuracyAll{i,1} = nan;
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
 

