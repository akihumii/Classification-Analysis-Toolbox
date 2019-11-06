function output = getAccuracyStats(data)
%GETACCURACYSTATS Get accuracy, sensitivity, specificity, MCC
%   output = getAccuracyStats(data)
numClass = size(data, 1);
for i = 1:size(data, 1)
    locsRemaining = getRemainingIndex(numClass, i);
    TN = sum(sum(data(locsRemaining, locsRemaining)));
    FP = sum(data(locsRemaining,i));
    FN = sum(data(i,locsRemaining));
    TP = data(i,i);
    statsAll.accuracy(i,1) = (TP+TN) / (TP+TN+FP+FN);
    statsAll.sensitivity(i,1) = TP / (TP+FN);  % TPR
    statsAll.specificity(i,1) = TN / (TN+FP);  % TNR
    statsAll.precision(i,1) = TP / (TP + FP);  % PPV
    statsAll.NPV(i,1) = TN / (TN + FN);
    statsAll.FNR(i,1) = FP / (FP + TN);  % miss rate
    statsAll.FPR(i,1) = FP / (FP + TN);  % fall-out
    statsAll.FDR(i,1) = FP / (FP + TP);  % False Discovery Rate
    statsAll.FOR(i,1) = FN / (FN + TN);  % False Omission Rate
    statsAll.TS(i,1) = TP / (TP + FN + FP);  % Threat Score / Critical Success Index (CSI)
    statsAll.F1(i,1) = 2*TP / (2*TP + FN + FP);
    statsAll.MCC(i,1) = ((TP*TN) - (FP*FN)) /...
                 sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
    statsAll.BM(i,1) = statsAll.sensitivity(i,1) + statsAll.specificity(i,1) - 1;  % Informedness / Bookmaker Informedness
    statsAll.MK(i,1) = statsAll.precision(i,1) + statsAll.NPV(i,1) - 1;  % Markedness
end            

output = statsAll;
% fieldnamesAll = fieldnames(statsAll);
% for i = 1:numel(fieldnamesAll)
%     output.(fieldnamesAll{i,1}) = mean(statsAll.(fieldnamesAll{i,1}));
% end
% output.statsAll = statsAll;
end

