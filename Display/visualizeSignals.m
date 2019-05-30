function windowsValues = visualizeSignals(signal, signalClassification, rasterLocs, parameters, PP)
%visualizeSignal Visualize needed signals. Raw, filtered, differential,
%overlapping windows, average windows, and overall signal with indicated
%spikes can be plotted.
% Average window will be show/save according to the input of
% 'showOverlap/saveOverlap'.
% Overall signal with spikes indicated will be show only when the input 
% 'showOverlap' is 1 and will not be saved.
% input: parameters: selectedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT
%   [] = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, saveRaw, showRaw, saveDelta, showDelta, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)

%% plotting parameters
PP.overlappingYMult = getAxisMultiplier(PP.overlappingYUnit);
PP.filteredYMult = getAxisMultiplier(PP.filteredYUnit);
PP.rawYMult = getAxisMultiplier(PP.rawYUnit);
PP.overallYMult = getAxisMultiplier(PP.overallYUnit);
PP.averageYMult = getAxisMultiplier(PP.averageYUnit);

if ~strcmp(PP.overlappingYLimit,'auto'); PP.overlappingYLimit = PP.overlappingYMult * PP.overlappingYLimit; end
if ~strcmp(PP.filteredYLimit, 'auto'); PP.filteredYLimit = PP.filteredYMult * PP.filteredYLimit; end
if ~strcmp(PP.rawYLimit, 'auto'); PP.rawYLimit = PP.rawYMult * PP.rawYLimit; end
if ~strcmp(PP.overallYLimit, 'auto'); PP.overallYLimit = PP.overallYMult * PP.overallYLimit; end 
if ~strcmp(PP.averageYLimit, 'auto'); PP.averageYLimit = PP.averageYMult * PP.averageYLimit; end

%% Partial Data Selectiom
for i = 1:length(signal)
    if parameters.partialDataSelection
        partialDataStartingTime{i,1} = [' (',num2str(signal(i,1).time(1) / signal(i,1).samplingFreq)];
        partialDataEndTime{i,1} = [' - ', num2str(signal(i,1).time(end) / signal(i,1).samplingFreq), ' s) '];
    else
        partialDataStartingTime{i,1} = '';
        partialDataEndTime{i,1} = '';
    end
end

%% Plot raw signal
titleRaw = 'Raw Signal';
if parameters.saveRaw || parameters.showRaw
    for i = 1:length(signal)
        [dataTemp, channelTemp, timeTemp] = bindSyncNCounter(PP.rawYMult*signal(i,1).dataRaw, parameters, signal(i,1));
        plotFig(timeTemp/signal(i,1).samplingFreq,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],titleRaw,'Time (s)','Amplitude (V)',parameters.saveRaw,parameters.showRaw,signal(i,1).path,'subplot', channelTemp, 'linePlot', PP.rawYLimit);
    end
end

%% Plot rectified signal
if parameters.saveRectified || parameters.showRectified
    for i = 1:length(signal)
        [dataTemp, ~, timeTemp] = bindSyncNCounter(signal(i,1).dataRectified, parameters, signal(i,1));
        plotFig(timeTemp/signal(i,1).samplingFreq,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Rectified Signal (High Pass Filtered 1 Hz)','Time (s)','Amplitude (V)',parameters.saveRectified,parameters.showRectified,signal(i,1).path,'subplot', signal(i,1).channelTemp);
    end
end

%% Plot differential signal
if parameters.saveDifferential || parameters.showDifferential
    for i = 1:length(signal)
        if isempty(signal(i,1).channelPair)
            if parameters.saveDifferential == 1 || parameters.showDifferential == 1
                warning('ChannelRef is not keyed in...')
            end
        else
            [dataTemp, channelTemp, timeTemp] = bindSyncNCounter(signal(i,1).dataDifferential, parameters, signal(i,1));
            plotFig(timeTemp/signal(i,1).samplingFreq,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Differential Signal Channel','Time(s)','Amplitude (V)',parameters.saveDifferential,parameters.showDifferential,signal(i,1).path,'subplot', channelTemp);
        end
    end
end

%% Plot filtered signal
titleFiltered = ['Filtered Signal (', num2str(signal(i,1).dataFiltered.highPassCutoffFreq),'-', num2str(signal(i,1).dataFiltered.lowPassCutoffFreq), ')'];
if parameters.saveFilt || parameters.showFilt
    if signal(i,1).dataFiltered.highPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.lowPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.notchFreq ~= 0
        for i = 1:length(signal)
            [dataTemp, channelTemp, timeTemp] = bindSyncNCounter(PP.filteredYMult*signal(i,1).dataFiltered.values, parameters, signal(i,1));
            plotFig(timeTemp/signal(i,1).samplingFreq,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],titleFiltered,'Time (s)',['Amplitude (',PP.filteredYUnit,')'],parameters.saveFilt,parameters.showFilt,signal(i,1).path,'subplot', channelTemp,'linePlot',PP.filteredYLimit);
        end
    end
end

%% Plot FFT signal
if parameters.saveFFT || parameters.showFFT
    for i = 1:length(signal)
        [dataTemp, channelTemp, ~] = bindSyncNCounter(signal(i,1).dataFFT.values, parameters, signal(i,1));
        plotFig(signal(i,1).dataFFT.freqDomain,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],[signal(i,1).dataFFT.dataBeingProcessed,' FFT Signal'],'Frequency (Hz)','Amplitude',parameters.saveFFT,parameters.showFFT,signal(i,1).path,'subplot', channelTemp);
    end
end

%% Plot windows following stimulation artefacts
if parameters.noClassification
    windowsValues(i,1) = nan;
else    
    for i = 1:length(signalClassification)
        %% Plot the data for peak detection
        if isequal(parameters.dataToBeDetectedSpike, 'dataFiltered') || isequal(parameters.dataToBeDetectedSpike, 'dataTKEO')
            parameters.dataToBeDetectedSpike = [{parameters.dataToBeDetectedSpike};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValuesPeakDetection, dataNamePeakDetection] = loadMultiLayerStruct(signal(i,1),parameters.dataToBeDetectedSpike);
        
        numChannel = size(signalClassification(i,1).burstDetection.spikeLocs,2);
        overallP = plotFig(signal(i,1).time/signal(i,1).samplingFreq,dataValuesPeakDetection,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Signal used for Peak Detection (', dataNamePeakDetection, ')'],'Time (s)','Amplitude (V)',...
            0,... % save
            1,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
        hold on
        
        % Plot the markings
        for j = 1:numChannel
            plotMarkings(overallP(j,1), signal(i,1).time/signal(i,1).samplingFreq, dataValuesPeakDetection(:,j), signalClassification(i,1).burstDetection.spikeLocs(:,j), signalClassification(i,1).burstDetection.burstEndLocs(:,j), signalClassification(i,1).burstDetection.threshold(j,1))
        end
        
        %% Plot Overlapping Signals
        if isequal(parameters.overlappedWindow, 'dataFiltered') || isequal(parameters.overlappedWindow, 'dataTKEO')
            parameters.overlappedWindow = [{parameters.overlappedWindow};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValues, dataName] = loadMultiLayerStruct(signal(i,1),parameters.overlappedWindow); % get the values and the name of the selected window
        
        maxBurstLength = max(signalClassification(i,1).burstDetection.burstEndLocs - signalClassification(i,1).burstDetection.spikeLocs,[],1);
        
        windowsValues(i,1) = getPointsWithinRange(...
            signal(i,1).time/signal(i,1).samplingFreq,...
            dataValues,...
            signalClassification(i,1).burstDetection.spikeLocs,...
            signalClassification(i,1).burstDetection.spikeLocs + repmat(maxBurstLength*parameters.overlapWindowLengthMult,size(signalClassification(i,1).burstDetection.spikeLocs,1),1),...
            parameters.windowSize, signal(i,1).samplingFreq, parameters.channelExtractStartingLocs);
        
        % Get all windows in same plots
%         windowsValues(i,1).xAxisValues = reshape(windowsValues(i,1).xAxisValues,[],2*size(windowsValues(i,1).xAxisValues,2));
%         windowsValues(i,1).burst = reshape(windowsValues(i,1).burst,[],2*size(windowsValues(i,1).burst,2));
        
        % Plot overlapping windows
        overlapP = plotFig(windowsValues(i,1).xAxisValues,PP.overlappingYMult*windowsValues(i,1).burst,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Windows Following Artefacts ( ', dataName, ' )'],'Time (s)',['Amplitude (',PP.overlappingYUnit,')'],...
            parameters.saveOverlap,... % save
            parameters.showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair, 'linePlot', PP.overlappingYLimit);
        
        % plot averaging overlapping windows
        plotFig(windowsValues(i,1).xAxisValues,PP.averageYMult*nanmean(windowsValues(i,1).burst,2),[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Average Windows Following Artefacts ( ', dataName, ' )'],'Time(s)',['Amplitude (',PP.averageYUnit,')'],...
            parameters.saveOverlap,... % save
            parameters.showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair,'linePlot',PP.averageYLimit);
        
        % plot overall signal with spikes indicated
        if parameters.showOverlap || parameters.saveOverlap
            [dataTemp, channelTemp, timeTemp] = bindSyncNCounter(PP.overallYMult*dataValues, parameters, signal(i,1));
            overallP = plotFig(timeTemp/signal(i,1).samplingFreq,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Overall Signal with Spikes Indicated (', dataName, ')'],'Time(s)',['Amplitude (',PP.overallYUnit,')'],...
                0,... % save
                1,... % show
                signal(i,1).path,'subplot', channelTemp,'linePlot',PP.overallYLimit);
            hold on
            
            % Plot the markings
            for j = 1:numChannel
                plotMarkings(overallP(j,1), signal(i,1).time/signal(i,1).samplingFreq, dataValues(:,j), signalClassification(i,1).burstDetection.spikeLocs(:,j), signalClassification(i,1).burstDetection.burstEndLocs(:,j), nan)                
            end
            
            % Save
            if parameters.saveOverlap
                savePlot(signal(i,1).path,['Overall Signal with Spikes Indicated (', dataName, ')'],[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])
            end
            if ~parameters.showOverlap
                close gcf
                delete overallP overlapP
            end
        end
    end
end

%% Plot comparison
if parameters.showCompare || parameters.saveCompare
    numSubplot = 2 + parameters.showSyncPulse + parameters.showCounter;
    for i = 1:length(signal)
        numPlot = size(signal(i,1).dataRaw, 2);
        for j = 1:numPlot
            if parameters.channelAveragingFlag
                usedChannels = ['Average of ',checkMatNAddStr(parameters.channelAveraging{j,1}, ',', 1)];
            else
                usedChannels = num2str(parameters.channel(1,j));
            end
            
            figure
            hold on;
            set(gcf, 'Position', get(0,'Screensize')-[0 0 0 80],'PaperPositionMode', 'auto');
            
            p(j,1) = subplot(numSubplot,1,1);
            plot(signal(i,1).time/signal(i,1).samplingFreq, signal(i,1).dataRaw(:,j));
            ylabel('Amplitude (V)');
            title([titleRaw, signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}, ' Channel ',usedChannels])
            
            p(j,2) = subplot(numSubplot,1,2);
            plot(signal(i,1).time/signal(i,1).samplingFreq, signal(i,1).dataFiltered.values(:,j));
            ylabel('Amplitude (V)');
            xlabel('Time (s)')
            title([titleFiltered, signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])
            
            iCurrentSubplot = 3;
            if parameters.showSyncPulse
                p(j,iCurrentSubplot) = subplot(numSubplot,1,iCurrentSubplot);
                plot(signal(i,1).time/signal(i,1).samplingFreq, signal(i,1).dataAll(:,11));
                ylabel('Amplitude');
                xlabel('Time (s)')
                title(['Sync pulse ', signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])
                iCurrentSubplot = iCurrentSubplot + 1;
            end
            if parameters.showCounter
                p(j,iCurrentSubplot) = subplot(numSubplot,1,iCurrentSubplot);
                plot(signal(i,1).time/signal(i,1).samplingFreq, signal(i,1).dataAll(:,12));
                ylabel('Amplitude');
                xlabel('Time (s)')
                title(['Counter ', signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])             
            end
            
            linkaxes(p, 'x');
            
            % Save
            if parameters.saveCompare
                savePlot(signal(i,1).path,'Comparison raw and filtered data',['Comparison raw and filtered data ', signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}, ' Channel ',num2str(j)],[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}, ' Channel ',num2str(j)])
            end
            if ~parameters.showCompare
                close gcf
            end

        end
    end
end

%% Plot raster plot
if parameters.saveRaster || parameters.showRaster
    for i = 1:length(signal)
        titleFig = ['Raster plot ', signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}];
        plotRaster(rasterLocs/signal.samplingFreq, signalClassification(i,1).burstDetection.spikeLocs/signal.samplingFreq)
        title([titleFig, ' (Threshold: ', num2str(parameters.threshold), ')'])
        
        if parameters.saveRaster
            savePlot(signal(i,1).path,'Raster plot', titleFig ,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])
        end
        if ~parameters.showRaster
            close gcf
        end
    end
end

end

function plotRaster(rasterLocs, spikeLocs)
[numRowSpikes, numCol] = size(spikeLocs);
numRowRaster = size(rasterLocs, 1);

% get the y axis matrix for plotting
ySpikes = repmat(1:numCol, numRowSpikes, 1);
yRaster = repmat(1:numCol, numRowRaster, 1);
yRaster = yRaster(:)';
yRaster = [yRaster-0.05; yRaster+0.05];

% plots
f = plotFig(spikeLocs, ySpikes, '', 'Raster plot', 'Time (s)', 'Channel', 0, 1, '', 'overlap', 0, 'scatterPlot', [0, numCol+1]);
hold on
scatterP = findobj(f, 'Type', 'scatter');
for i = 1:length(scatterP)
    scatterP(i,1).SizeData = 100;
end
lRaster = plot(repmat(rasterLocs(:)',2,1), yRaster, 'k');
f.Children = circshift(f.Children,2);
% lRaster = plot(rasterLocs, yRaster, 'kx', 'MarkerSize', 6);
legend(lRaster, 'Stimulation')
end

function [dataNew, channelNew, timeNew] = bindSyncNCounter(data, parameters, signal)
dataNew = data;
channelNew = signal.channel;
if parameters.showSyncPulse
    dataNew = [dataNew, signal.dataAll(:,11)];
    if size(channelNew,1) == 1
        channelNew = [channelNew, 100];
    else
        channelNew = [channelNew, repmat(100,size(channelNew,2))];
    end
end
if parameters.showCounter
    dataNew = [dataNew, signal.dataAll(:,12)];
    if size(channelNew,1) == 1
        channelNew = [channelNew, 200];
    else
         channelNew = [channelNew, repmat(200,size(channelNew,2))];
    end
end
timeNew = repmat(signal.time(:,1),1,size(dataNew,2));
end

function output = getAxisMultiplier(unit)
if strfind(unit,'u')
    output = 1e6;
elseif strfind(unit,'m')
    output = 1e3;
else
    output = 1;
end
end