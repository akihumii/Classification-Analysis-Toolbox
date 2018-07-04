function output = runPrediction(classifierOutput,threshPercentile)
%runPrediction Run classifier in the analyzeFeatures
% output: prediction: accuracyTemp: [featureDimension x channel x iter]
%   output = runClassifier(classifierOutput,pcaInfo)

%% Read files
[filesTest,pathTest,iterTest] = selectFiles('select mat files for testing classifier');
if iterTest == 1
    disp([num2str(iterTest), ' file has been selected'])
else
    disp([num2str(iterTest), ' files have been selected'])
end

%% Run classifier
popMsg('Processing classifier testing...');
tTesting = tic;

% initiate required variables
numFeatureSet = length(classifierOutput.classificationOutput); % number of feature dimensions used for classification, eg numFeatureSet = 2 means that there is up to 2-D of classification
numChannel = length(classifierOutput.classificationOutput{1,1}.Mdl);

groupedFeature = cell(numFeatureSet,numChannel,iterTest);
predictClass = cell(numFeatureSet,numChannel,iterTest);
accuracyTemp = cell(numFeatureSet,numChannel,iterTest);

for i = 1:iterTest % test the classifier
    testSignalInfo(i,1) = getFeaturesInfo(pathTest,filesTest{1,i});
    
    testPCAInfo(i,1) = reconstructPCA(testSignalInfo(i,1),threshPercentile); % matrix in [class x channel]
    
    testFeaturesRaw{i,1} = reconstructSignalInfoFeatures(testSignalInfo(i,1));
    
    featuresInfo{i,1} = reconstructFeatures(testFeaturesRaw{i,1},1,testPCAInfo(i,1).numBursts); % as the raw features still contains Nan, so number of bursts should not be trimmed too
    
    % assign the number in the filename into certain classes
    switch testSignalInfo(i,1).fileSpeed{1,1}
        case num2str(10)
            classTemp = 1;
        case num2str(15)
            classTemp = 2;
        otherwise
            error('Invalid input class...')
    end
    
    for j = 1:numFeatureSet
        for k = 1:numChannel
            trainingRatio = 0;
            groupedFeature{j,k,i}(:,1) = combineFeatureWithoutNan(featuresInfo{i,1}.featuresAll(:,classifierOutput.featureIndex{j,1}(1,:),k),trainingRatio,1);
            
            try
                predictClass{j,k,i}(:,1) = predict(classifierOutput.classificationOutput{j,1}.Mdl{k},groupedFeature{j,k,i}(:,end).testing); % get the prediction
                accuracyTemp{j,k,i}(1,:) = calculateAccuracy(predictClass{j,k,i}(:,end),ones(size(predictClass{j,k,i}(:,end)))*classTemp);
            catch
                predictClass{j,k,i}(:,1) = 0;
                accuracyTemp{j,k,i}(1,:) = calculateAccuracy(nan,nan);
            end
            
        end
    end
    %     predictionOutput(i,1) = discreteClassification(testSignalInfo(i,1).dataTKEOTest,testSignalInfo(i,1).dataFilteredTest,testSignalInfo(i,1).samplingFreqTest,windowSize,windowSkipSize,testSignalInfo(i,1).detectionInfoTest,classifierOutput.featureIndex,classifierOutput.coefficient,correctClass);
end

% Compute the average
for i = 1:iterTest
    for j = 1:numFeatureSet
        for k = 1:numChannel
            resultedAccuracy(j,k,i) = getBasicParameter(vertcat(accuracyTemp{j,k,i}.accuracy));
        end
    end
end

% for i = 1:iterTest % visualize the classifier
%     visualizeDetectedPoints(dataFilteredTest{i,1},predictionOutput(i,1).startPointAll,predictionOutput(i,1).endPointAll,samplingFreqTest(1,1),fileNameTest{i,1},pathTest);
% end

% display(['Continuous classification takes ',num2str(toc(tTrain)),' seconds...']);

%% Output
output.resultedAccuracy = resultedAccuracy;
output.prediction = accuracyTemp;
output.predictClass = predictClass;
output.signalInfo = testSignalInfo;
output.iterTest = iterTest;

end

