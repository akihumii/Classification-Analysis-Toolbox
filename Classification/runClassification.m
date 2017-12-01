function output = runClassification(name, signalClassification)
%runClassification Summary of this function goes here
%   Detailed explanation goes here
output = classifier(name);
output = classification(output,signalClassification);
end

