function output = knnClassification(trainingTemp,trainingClassTemp,testingTemp)
%knnClassification Train and obtain the model of knn classifier.
% 
%   output = knnClassification(trainingTemp,trainingClassTemp,testingTemp)

numNeighbours = 1; % fine knn

Mdl = fitcknn(trainingTemp,trainingClassTemp,'NumNeighbors',numNeighbours,'Standardize',1);

predictClass = predict(Mdl,testingTemp);

%% output
output.predictClass = predictClass;
end

