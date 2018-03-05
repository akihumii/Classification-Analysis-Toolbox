function [] = plotAllSeparatedBursts(signalInfo,numClass,numChannel,featuresInfo,plotFileName,path)
%plotAllSeparatedBursts Plot all the separated bursts arranged by bursts
%length. This is used in visualizeFeatures.
% 
%   Detailed explanation goes here

samplingFreq = signalInfo(1,1).signal.samplingFreq;

burstLength = squeeze(featuresInfo.featuresAll(:,3,:)); % extract bursts length from featuresInfo [class x channel]

windowSize = [0,0.01];

for j = 1:numChannel
    maxBurstLengthTemp = max(vertcat(burstLength{:,j}));
    timeAxis{j,1} = 0:1/samplingFreq:(maxBurstLengthTemp+windowSize(1,2));
    for i = 1:numClass
        timeAxisFull{i,1} = 0:1/samplingFreq:size(signalInfo(i,1).signal.dataFiltered.values,2);
        dataFiltered{i,j} = signalInfo(i,1).signal.dataFiltered.values(:,j); % matrix of cells with [class x channel]
        startingLocs{i,j} = signalInfo(i,1).signalClassification.burstDetection.spikeLocs(:,j);
        startingLocs{i,j} = omitNan(startingLocs{i,j},2,'all'); % clear Nan
        endLocs{i,j} = signalInfo(i,1).signalClassification.burstDetection.burstEndLocs(:,j);
        endLocs{i,j} = omitNan(endLocs{i,j},2,'all'); % clear Nan
        
        numBursts = length(startingLocs{i,j});
        burstsInfo{i,j} = getPointsWithinRange(timeAxisFull{i,1},dataFiltered{i,j},startingLocs{i,j},startingLocs{i,j} + maxBurstLengthTemp*samplingFreq,[0,0.01],samplingFreq,0); % [class x channel]
    end
end


%% Arrange bursts according to their burst lengths descendently
for i = 1:numChannel
    burstLengthTemp = vertcat(burstLength{:,i});
    [~,burstArrangedLocs] = sort(burstLengthTemp,1,'descend');
    burstsInfoSorted{1,i} = vertcat(burstsInfo{:,i});
    burstsSorted{1,i} = horzcat(burstsInfoSorted{1,i}(:,1).burst);
    burstsSorted{1,i} = burstsSorted{1,i}(:,burstArrangedLocs);
    
    startingLocsSorted{1,i} = vertcat(startingLocs{:,i});
    startingLocsSorted{1,i} = startingLocsSorted{1,i}(burstArrangedLocs);
    
    endLocsSorted{1,i} = vertcat(endLocs{:,i});
    endLocsSorted{1,i} = endLocsSorted{1,i}(burstArrangedLocs);
end

%% Plot Bursts with Starting Locs and End Locs
for i = 1:numChannel
    numBurstTemp = length(startingLocsSorted{1,i});
    arrayTemp = sort2cellFraction(numBurstTemp,10);
    numArray = length(arrayTemp);
    for j = 1:numArray
        plotFig(timeAxis{j,1},burstsSorted{1,i}(:,arrayTemp{j,1}),plotFileName,'Full Length Bursts','Time (s)','Amplitude (V)',0,1,path,'subplot',0);
    end
end


end



