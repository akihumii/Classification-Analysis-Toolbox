function output = runPrediction(classifierOutput,threshPercentile)
%runPrediction Run classifier in the analyzeFeatures
% output: prediction: accuracyTemp: [featureDimension x channel x iter]
%   output = runClassifier(classifierOutput,pcaInfo)

%% Parameters
windowSize = 0.5; % window size in seconds
windowSkipSize = 0.05; % skipped window size in seconds
correctClass = 1; % real class of the signal bursts

%% Read files
[filesTest,pathTest,iterTest] = selectFiles('select mat files for testing classifier');

%% Run classifier
popMsg('Processing continuous classification...');

for i = 1:iterTest % test the classifier
    testSignalInfo(i,1) = getFeaturesInfo(pathTest,filesTest{i,1});

    testPCAInfo(i,1) = reconstructPCA(testSignalInfo,threshPercentile); % matrix in [class x channel]

    testFeaturesRaw{i,1} = reconstructSignalInfoFeatures(testSignalInfo(i,1));
    
    featuresInfo{i,1} = reconstructFeatures(testFeaturesRaw{i,1},1,testPCAInfo(i,1).numBursts); % as the raw features still contains Nan, so number of bursts should not be trimmed too
    

    switch testSignalInfo(i,1).fileSpeed{1,1}
        case num2str(10)
            classTemp = 1;
        case num2str(15)
            classTemp = 2;
        otherwise
            error('Invalid input class...')
    end
    
    numFeatureSet = length(classifierOutput.classificationOutput); % number of feature dimensions used for classification, eg numFeatureSet = 2 means that there is up to 2-D of classification
    numChannel = length(classifierOutput.classificationOutput{1,1}.Mdl);
    for j = 1:numFeatureSet
        for k = 1:numChannel
            trainingRatio = 0;
            groupedFeature(j,k,i) = combineFeatureWithoutNan(featuresInfo{i,1}.featuresAll(:,classifierOutput.featureIndex{j,1}(1,:),k),trainingRatio,iterTest);
            
            predictClass{j,k,i} = predict(classifierOutput.classificationOutput{j,1}.Mdl{k},groupedFeature(j,k,i).testing); % get the prediction
            
            accuracyTemp(j,k,i) = calculateAccuracy(predictClass{j,k,i},ones(size(predictClass{j,k}))*classTemp);
        end
    end
    
%     predictionOutput(i,1) = discreteClassification(testSignalInfo(i,1).dataTKEOTest,testSignalInfo(i,1).dataFilteredTest,testSignalInfo(i,1).samplingFreqTest,windowSize,windowSkipSize,testSignalInfo(i,1).detectionInfoTest,classifierOutput.featureIndex,classifierOutput.coefficient,correctClass);
end

% for i = 1:iterTest % visualize the classifier
%     visualizeDetectedPoints(dataFilteredTest{i,1},predictionOutput(i,1).startPointAll,predictionOutput(i,1).endPointAll,samplingFreqTest(1,1),fileNameTest{i,1},pathTest);
% end

% display(['Continuous classification takes ',num2str(toc(tTrain)),' seconds...']);

%% Output
output.prediction = accuracyTemp;
output.predictClass = predictClass;
output.signalInfo = testSignalInfo;

end

