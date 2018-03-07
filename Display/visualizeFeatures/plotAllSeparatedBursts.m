function [] = plotAllSeparatedBursts(signalInfo,numClass,numChannel,featuresInfo,plotFileName,path,displayInfo)
%plotAllSeparatedBursts Plot all the separated bursts arranged by bursts
%length. This is used in visualizeFeatures.
% 
%   Detailed explanation goes here

samplingFreq = signalInfo(1,1).signal.samplingFreq;

burstLength = squeeze(featuresInfo.featuresAll(:,3,:)); % extract bursts length from featuresInfo [class x channel]

windowSize = [0,0.01];

for j = 1:numChannel
    maxBurstLengthTemp = max(vertcat(burstLength{:,j}));
    timeAxis{j,1} = signalInfo(1,1).windowsValues.xAxisValues(:,1,j);
    for i = 1:numClass
        timeAxisFull{i,1} = 0:1/samplingFreq:size(signalInfo(i,1).signal.dataFiltered.values,2);
        dataFiltered{i,j} = signalInfo(i,1).signal.dataFiltered.values(:,j); % matrix of cells with [class x channel]
        startingLocs{i,j} = signalInfo(i,1).signalClassification.burstDetection.spikeLocs(:,j);
        startingLocs{i,j} = omitNan(startingLocs{i,j},2,'all'); % clear Nan
        endLocs{i,j} = signalInfo(i,1).signalClassification.burstDetection.burstEndLocs(:,j);
        endLocs{i,j} = omitNan(endLocs{i,j},2,'all'); % clear Nan
        
        numBursts = length(startingLocs{i,j});
        burstsInfo{i,j} = signalInfo(i,1).windowsValues.burst(:,:,j);
%         burstsInfo{i,j} = getPointsWithinRange(timeAxisFull{i,1},dataFiltered{i,j},startingLocs{i,j},startingLocs{i,j} + maxBurstLengthTemp*samplingFreq,[0,0.01],samplingFreq,0); % [class x channel]
    end
end


%% Arrange bursts according to their burst lengths descendently
for i = 1:numChannel
    burstLengthTemp = vertcat(burstLength{:,i});
    [~,burstArrangedLocs{1,i}] = sort(burstLengthTemp,1,'descend');
%     burstsInfoSorted{1,i} = vertcat(burstsInfo{:,i});
%     burstsSorted{1,i} = horzcat(burstsInfoSorted{1,i}(:,1).burst);
    burstsSorted{1,i} = catNanMat(burstsInfo(:,i),2,'all');
    burstsSorted{1,i} = burstsSorted{1,i}(:,burstArrangedLocs{1,i});
    
    startingLocsSorted{1,i} = vertcat(startingLocs{:,i});
    startingLocsSorted{1,i} = startingLocsSorted{1,i}(burstArrangedLocs{1,i});
    
    endLocsSorted{1,i} = vertcat(endLocs{:,i});
    endLocsSorted{1,i} = endLocsSorted{1,i}(burstArrangedLocs{1,i});
end

%% Plot Bursts with Starting Locs and End Locs
for i = 1:numChannel
    numRowSubplots = 10; % number of subplots in row
    flagPlotLessBurstsColumn = 0; % to plot the column of bursts subplot that does not have 10 subplots
    flagPlotSingleColumn = 0; % to plot the unpaired full bursts subplot column
    numBurstTemp = length(startingLocsSorted{1,i}); % number of total subpltos (bursts)
    arrayTemp = sort2cellFraction(1:numBurstTemp,numRowSubplots); % array to plots the subplots in column
    numArray = length(arrayTemp); % number of columns plotted in a figure
    xLimitTemp = omitNan(timeAxis{i,1},2,'all'); % the array without Nan
    xLimit = [xLimitTemp(1,1),xLimitTemp(end,1)]; % x limit of the subplots, which is the full length of the longest bursts
    
    % plot columns of bursts
    for j = 1:numArray
        [pFullBursts{j,1},fFullBursts(j,1)] = plotFig(timeAxis{i,1},burstsSorted{1,i}(:,arrayTemp{j,1}),plotFileName,['Full Length Bursts Channel ', num2str(i)],'Time (s)','Amplitude (V)',0,1,path,'subplot',arrayTemp{j,1});
        xlim(xLimit)
        hold on
        % plot starting locs and end locs
        numSubplots = length(pFullBursts{j,1});
        for k = 1:numSubplots
            endLocsTemp = endLocsSorted{1,i}(arrayTemp{j,1}(k)) - startingLocsSorted{1,i}(arrayTemp{j,1}(k)); % unit in sample points
            endLocsMark = plot(pFullBursts{j,1}(k),endLocsTemp/samplingFreq,burstsSorted{1,i}(endLocsTemp,arrayTemp{j,1}(k)),'rx');
        end
        legend(endLocsMark,'Burst offset point')
    end
    
    % combined them into 2 columns
    numFullBurstsPlots = length(pFullBursts); % number of figures
    if length(pFullBursts{end,1}) ~= numRowSubplots % the number of subplots in last column is not equal to 10
        arrayFullBursts = sort2cellFraction(1:numFullBurstsPlots-1,2); % array of figures to be plotted in a new combined figure
        flagPlotLessBurstsColumn = 1;
    else
        arrayFullBursts = sort2cellFraction(1:numFullBurstsPlots,2);
    end
    
    if length(arrayFullBursts{end,1}) ~= 2 % number of final pair is not equal to 2
        numArrayFullBursts = length(arrayFullBursts)-1; % number of combined figures
        flagPlotSingleColumn = 1;
    else
        numArrayFullBursts = length(arrayFullBursts);
    end
    
    for numSaveSubplot = 1:numArrayFullBursts
        [pCombinedSubplots{numSaveSubplot,1},fCombinedSubplots(numSaveSubplot,1)] = plots2subplots(vertcat(pFullBursts{arrayFullBursts{numSaveSubplot,1}}),numRowSubplots,2);
        delete(fFullBursts(arrayFullBursts{numSaveSubplot,1}));
        
        legend(pCombinedSubplots{1,1}(1,2).Children(1),'Burst offset point');
        
        if displayInfo.saveReconstruction % save combined figures
            savePlot(path,'Combined Full Length Bursts Subplots',plotFileName,['Combined Full Length Bursts Ch ',num2str(i),' Suplots ',num2str(numSaveSubplot)])
        end
    end
    
    if flagPlotSingleColumn && displayInfo.saveReconstruction
        numSaveSubplot = numSaveSubplot + 1;
        savePlot(path,'Combined Full Length Bursts Subplots',plotFileName,['Combined Full Length Bursts Ch ',num2str(i),' Suplots ',num2str(numSaveSubplot)],fFullBursts(arrayFullBursts{end,1}))
    end
    
    if flagPlotLessBurstsColumn && displayInfo.saveReconstruction
        numSaveSubplot = numSaveSubplot + 1;
        savePlot(path,'Combined Full Length Bursts Subplots',plotFileName,['Combined Full Length Bursts Ch ',num2str(i),' Suplots ',num2str(numSaveSubplot)],fFullBursts(end,1))
    end

    if ~displayInfo.showReconstruction 
        delete(fFullBursts(:,1))
        delete(fCombinedSubplots(:,1))
    end
    
    clear pFullBursts fFullBursts pCombinedSubplots fCombinedSubplots
end


end



