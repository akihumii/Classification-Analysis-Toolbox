function output = checkOnlineAccuracy(predictClass, burstExistsFlag)
%CHECKONLINEACCURACY Check accuracy of the online classification by
%checking the prediction class and the burstExistsFlag.
% output:   TP: predictClass=1, burstExists=1
%           FP: predictClass=1, burstExists=0
%           TN: predictClass=0, burstExists=0
%           FN: predictClass=0, burstExists=1
% 
%   output = checkOnlineAccuracy(predictClass, burstExistsFlag)

numChannel = size(burstExistsFlag,2);

for i = 1:numChannel
    positive = find(predictClass(:,i));
    negative = find(~predictClass(:,i));
    
    numPositive = length(positive);
    numNegative = length(negative);
    
    TP(i,1) = length(find(burstExistsFlag(positive,i)));
    TN(i,1) = length(find(~burstExistsFlag(negative,i)));
    
    FP(i,1) = numPositive - TP(i,1);
    FN(i,1) = numNegative - TN(i,1);
end

output = makeStruct(TP,FP,TN,FN); 

end

