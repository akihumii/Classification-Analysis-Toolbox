function output = runClassifier(classifierOutput)
%runClassifier Run classifier in the analyzeFeatures
%   Detailed explanation goes here

%% Parameters
windowSize = 0.5; % window size in seconds
windowSkipSize = 0.05; % skipped window size in seconds
correctClass = 1; % real class of the signal bursts

%% Read files
[filesTest,pathTest,iterTest] = selectFiles('select mat files for continuous classifier''s testing');


%% Run classifier
popMsg('Processing continuous classification...');

for i = 1:iterTest % test the classifier
    testSignalInfo(i,1) = getFeaturesInfo(pathTest,fileTest);

    predictionOutput(i,1) = discreteClassification(testSignalInfo(i,1).dataTKEOTest,testSignalInfo(i,1).dataFilteredTest,testSignalInfo(i,1).samplingFreqTest,windowSize,windowSkipSize,testSignalInfo(i,1).detectionInfoTest,classifierOutput.featureIndex,classifierOutput.coefficient,correctClass);
end

for i = 1:iterTest % visualize the classifier
    visualizeDetectedPoints(dataFilteredTest{i,1},predictionOutput(i,1).startPointAll,predictionOutput(i,1).endPointAll,samplingFreqTest(1,1),fileNameTest{i,1},pathTest);
end

display(['Continuous classification takes ',num2str(toc(tTrain)),' seconds...']);

%% Output
output.prediction = predictionOutput;
output.signalInfo = testSignalInfo;

end

