function output = getAccuracyStats(data)
%GETACCURACYSTATS Get accuracy, sensitivity, specificity, MCC
%   output = getAccuracyStats(data)
            TN = data(1,1);
            FP = data(1,2);
            FN = data(2,1);
            TP = data(2,2);
            output.accuracy = (TP+TN) / (TP+TN+FP+FN);
            output.senstivity = TP / (TP+FN);
            output.specificity = TN / (TN+FP);
            output.MCC = ((TP*TN) - (FP*FN)) /...
                         sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
end

