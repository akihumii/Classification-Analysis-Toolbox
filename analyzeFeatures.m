%% Analyze features from multiple files
% Load features from multiple mat files and plot the figures

clear
close all
clc

%% User Input
showFigures = 1;
saveFigures = 0;

[files, path, iter] = selectFiles();

%% Get features
for i = 1:iter
    info(i,1) = load([path,files{i}]);
    signal(i,1) = info(i,1).varargin{1,1};
    signalClassification(i,1) = info(i,1).varargin{1,2};
    
    fileName{i,1} = signal(i,1).fileName;
    features{i,1} = signalClassification(i,1).features;
    fileSpeed{i,1} = fileName{i,1}(7:8);
    fileDate{i,1} = fileName{i,1}(12:17);
end

channel = signal(1,1).channel;
numChannel = length(channel);
featuresNames = fieldnames(features{1,1});
featuresNames(end) = []; % the field that containes analyzed data
numFeatures = length(featuresNames);

%% Reconstruct features
% matrix of one feature = [bursts x speeds x features x channel]
for i = 1:numFeatures
    for j = 1:iter % different speed
        for k = 1:numChannel
            featureNameTemp = featuresNames{i,1};
            featuresAll(:,j,i,k) = features{j,1}.(featureNameTemp)(:,k);
            featureMean(i,j,k) = mean(featuresAll(:,j,i,k));
            featureStd(i,j,k) = std(featuresAll(:,j,i,k));
        end
    end
end

numBursts = size(featuresAll,1);

%% Plot features
close all

dataPath = signal(1,1).path;
titleName = 'Different Speed';
switch titleName
    case 'Different Speed'
        plotFileName = [fileName{1,1}(1:6),fileName{1,1}(12:17)];
        xScale = 'Speed(cm/s)';
        xTickValue = fileSpeed;
    case 'Different Day';
        plotFileName = fileName{1,1}(1:8);
        xScale = 'Date';
        xTickValue = fileDate;
end
        

for i = 1:numFeatures
    for j = 1:numChannel
        [p(i,j),f(i,j)] = plotFig(1:iter,transpose(featureMean(i,:,j)),plotFileName,[featuresNames{i,1},' of ',titleName],xScale,'',...
            0,... % save
            1,... % show
            path, 'subPlot',channel(1,j),'barPlot');
        p(i,j).XTick = 1:iter;
        p(i,j).XTickLabel = xTickValue;
        hold on
        featureStde(i,:,j) = featureStd(i,:,j) / sqrt(numBursts);
        errorbar(1:iter,transpose(featureMean(i,:,j)),featureStde(i,:,j),'r*');
        
        if saveFigures
            savePlot(path,['Features sorted in ',titleName,],plotFileName,[featuresNames{i,1},' with ',titleName,' of ch ',num2str(channel(1,j)),' in ',plotFileName])
        end
        
    end
end

%% Plot all the features
for i = 1:numChannel
    plots2subplots(p(:,i),2,4)
end

if saveFigures
    savePlot(path,['Features sorted in ',titleName,],plotFileName,['All the Features with ',titleName,' of ch ',num2str(channel(1,j)),' in ',plotFileName])
end

if ~showFigures
    close all
end


clear i j k

finishMsg()


