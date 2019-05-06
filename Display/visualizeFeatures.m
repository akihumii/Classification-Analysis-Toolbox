function [] = visualizeFeatures(iter, path, classifierOutput, featuresInfo, signalInfo, displayInfo, pcaInfo, parameters)
%visualizeFeatures Visualize the features, accuracies, feature distribution
%    [] = visualizeFeatures(iter, path, channel, classificationOutput, featureIndex, accuracyBasicParameter, featuresInfo, titleName, fileName, signalInfo, saveFigures, showFigures, saveSeparatedFigures, showSeparatedFigures, saveHistFit, showHistFit, saveAccuracy, showAccuracy)
 
%% Parameters
[numClass, numFeatures, numChannel] = size(featuresInfo.featuresAll); % the sizes of the features properties
titleName = classifierOutput.classifierTitle; % title name
fileName = signalInfo(1,1).fileName; % file name
numRowSubplots = getFactors(numFeatures); % for the row of subplots in overall plots
channel = signalInfo(1,1).signal.channel; % channel
featureIndex = classifierOutput.featureIndex; % feature index
is2DClassification = length(featureIndex) == 2; % if 2 features are used in the combination to do the classification
colorArray = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840]; % for colormap
numPrinComp = 4; % number of principle component to be plotted
 
if numClass == 3
    xTickValue{3,1} = 'Noise';
end
 
%% Preparation
switch titleName
    case 'Different Speed'
        plotFileName = [fileName(1:6),fileName(12:17)];
        xScale = 'Speed';
        xTickValue = cat(1,signalInfo(:,1).fileSpeed);
    case 'Different Day'
        plotFileName = fileName(1:8);
        xScale = 'Week';
        xTickValue = cat(1,signalInfo(:,1).fileDate);
    case 'Active EMG'
        plotFileName = fileName;
        xScale = '';
        xTickValue = [{'non-activated EMG'};{'activated EMG'}];
end
 
if parameters.runPCA
    titleName = [titleName,' with PCA'];
end

%% Plot Features
if displayInfo.showFigures || displayInfo.saveFigures || displayInfo.showSeparatedFigures || displayInfo.saveSeparatedFigures
    plotFeatures(numFeatures,numChannel,iter,featuresInfo,plotFileName,xScale,path,channel,xTickValue,displayInfo,titleName,numRowSubplots)
end
 
%% Plot Accuracy and Synergy
if displayInfo.showAccuracy || displayInfo.saveAccuracy
    plotAccuracy(classifierOutput,featureIndex,plotFileName,path,numClass,xScale,xTickValue,displayInfo,numChannel,is2DClassification,channel,titleName,parameters.legendName);
end
 
%% Plot histogram and distribution
if displayInfo.showHistFit || displayInfo.saveHistFit
    %% (for single features in all classes)
    plotSingleFeatureDistribution(numChannel,numFeatures,featuresInfo,plotFileName,path,channel,numClass,colorArray,classifierOutput,2,xTickValue,xScale,displayInfo,titleName)
    
    %% for 2 features used in combinations
    if is2DClassification
        plotMultipleFeatureDistribution(numChannel,featuresInfo,plotFileName,channel,path,featureIndex,classifierOutput,xTickValue,xScale,displayInfo,numClass,colorArray,titleName);
    end
end

%% Plot the Principle Component Coefficients
if displayInfo.showPrinComp || displayInfo.savePrinComp
    plotPrinComp(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numPrinComp,titleName)
end

%% Plot and compare before and after reconstruction
if displayInfo.showReconstruction || displayInfo.saveReconstruction
    plotReconstruction(signalInfo,pcaInfo,numChannel,displayInfo,fileName,path,channel,plotFileName,numClass,titleName)
    plotMeanBurst(pcaInfo,fileName,path,titleName,numChannel,plotFileName,displayInfo);
    plotAllSeparatedBursts(signalInfo,pcaInfo,numClass,numChannel,featuresInfo,plotFileName,path,displayInfo,titleName); % plot original full length bursts
end

end
 
