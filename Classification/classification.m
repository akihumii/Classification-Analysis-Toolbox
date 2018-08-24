function output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat,classifierName)
%classification Perform lda classification with trials that are in cells.
% The structure is like: [channel * feature * class]
% 
%   output = classification(trials,featureIndex,trainingRatio,classifierTitle,numRepeat)
 
[numClasses,~,numChannels] = size(trials);
numSelectedFeatures = length(featureIndex);
 
for i = 1:numChannels
    accuracyHighest(1,i) = 0; % initialize accuracy
    
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

        accuracyAll(r,i) = accuracyTemp.accuracy;
        
%         if accuracyTemp.accuracy > accuracyHighest(1,i) % record the result from the classifier that has the highest performance
            accuracyHighest(1,i) = accuracyTemp.accuracy;
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
    accuracy(1,i) = mean(accuracyAll(:));
end
 
output.classifierTitle = classifierTitle;
% output.class = class;
output.Mdl = Mdl;
% output.error = error;
% output.posterior = posterior;
% output.logP = logP;
% output.coefficient = coefficient;
output.accuracy = accuracy; % a matrix of numbers which are the mean accuracy after all the repeatations
output.accuracyAll = accuracyAll;
output.accuracyHighest = accuracyHighest; % a structure containing accuracy, true positive and false negative
output.training = training;
output.testing = testing;
output.trainingClass = trainingClass;
output.testingClass = testingClass;
output.predictClass = predictClass;
end
 

