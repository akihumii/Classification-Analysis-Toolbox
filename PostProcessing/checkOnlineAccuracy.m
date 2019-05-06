function classificationInfo = checkOnlineAccuracy(predictClass, trueClass)
%CHECKONLINEACCURACY Check accuracy of the online classification by
%checking the prediction class and the burstExistsFlag.
% output:   classifiedGroup: (i,j) is the number of samples whose target is 
%           the ith class that was classified as j.
%           classifiedInd: ind{i,j} contains the indices of samples with
%           the ith target class. [TN, FP; FN, TP]
%           classifiedPer: column 1: false negative rate (false negatives)/(all output negatives)
%                          column 2: false positive rate (false positive)/(all output positive)
%                          column 3: true positive rate (true positive)/(all output positive)
%                          column 4: true negative rate (true negatives)/(all output negatives)
% 
%   output = checkOnlineAccuracy(predictClass, burstExistsFlag)

numChannel = length(trueClass);
yLimit = [-1e-3; 1e-3];

for i = 1:numChannel
    predictClassMat = mat2confusionMat(predictClass{i,1});
    burstExistsFlagMat = mat2confusionMat(trueClass{i,1});
    
    [misClassifiedPer, classifiedGroup, classifiedInd, classifiedPer] = ...
        confusion(burstExistsFlagMat, predictClassMat);
    
    accuracyPer = 1-misClassifiedPer;
    
%     figure
%     stem(repmat(classifiedInd{1,2},2,1),repmat(yLimit,1,length(classifiedInd{1,2})),'r')
%     hold on
%     stem(repmat(classifiedInd{2,2},2,1),repmat(yLimit,1,length(classifiedInd{2,2})),'g')
%     
    classificationInfo(i,1) = makeStruct(...
        accuracyPer, misClassifiedPer, classifiedGroup, classifiedInd, classifiedPer, predictClassMat, burstExistsFlagMat);
end


%% manually coded 
% for i = 1:numChannel
%     positive = find(predictClass(:,i));
%     negative = find(~predictClass(:,i));
%     
%     numPositive = length(positive);
%     numNegative = length(negative);
%     
%     TP(i,1) = length(find(burstExistsFlag(positive,i)));
%     TN(i,1) = length(find(~burstExistsFlag(negative,i)));
%     
%     FP(i,1) = numPositive - TP(i,1);
%     FN(i,1) = numNegative - TN(i,1);
% end

% output = makeStruct(TP,FP,TN,FN); 

end

