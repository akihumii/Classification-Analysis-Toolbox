function [channel1class1,channel1class2,channel2class1,channel2class2] = loadDataForClassifyLearner(featuresAll)
%loadDataForClassifyLearner Read the data info for the classification learner %app.
% 
%   Detailed explanation goes here

channel1class1 = horzcat(featuresAll{1,:,1});
channel1class2 = horzcat(featuresAll{2,:,1});
channel2class1 = horzcat(featuresAll{1,:,2});
channel2class2 = horzcat(featuresAll{2,:,2});

end

