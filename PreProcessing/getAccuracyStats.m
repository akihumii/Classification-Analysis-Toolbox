function output = getAccuracyStats(data)
%GETACCURACYSTATS Get accuracy, sensitivity, specificity, MCC
%   output = getAccuracyStats(data)
            TN = data(1,1);
            FP = data(1,2);
            FN = data(2,1);
            TP = data(2,2);
            output.accuracy = (TP+TN) / (TP+TN+FP+FN);
            output.sensitivity = TP / (TP+FN);  % TPR
            output.specificity = TN / (TN+FP);  % TNR
            output.precision = TP / (TP + FP);  % PPV
            output.NPV = TN / (TN + FN);
            output.FNR = FP / (FP + TN);  % miss rate
            output.FPR = FP / (FP + TN);  % fall-out
            output.FDR = FP / (FP + TP);  % False Discovery Rate
            output.FOR = FN / (FN + TN);  % False Omission Rate
            output.TS = TP / (TP + FN + FP);  % Threat Score / Critical Success Index (CSI)
            output.F1 = 2*TP / (2*TP + FN + FP);
            output.MCC = ((TP*TN) - (FP*FN)) /...
                         sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
            output.BM = output.sensitivity + output.specificity - 1;  % Informedness / Bookmaker Informedness
            output.MK = output.precision + output.NPV - 1;  % Markedness
            
end

