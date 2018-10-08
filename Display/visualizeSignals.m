function windowsValues = visualizeSignals(signal, signalClassification, parameters)
%visualizeSignal Visualize needed signals. Raw, filtered, differential,
%overlapping windows, average windows, and overall signal with indicated
%spikes can be plotted.
% Average window will be show/save according to the input of
% 'showOverlap/saveOverlap'.
% Overall signal with spikes indicated will be show only when the input 
% 'showOverlap' is 1 and will not be saved.
% input: parameters: selectedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT
%   [] = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, saveRaw, showRaw, saveDelta, showDelta, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)

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
if ~parameters.saveRaw && ~parameters.showRaw
else
    for i = 1:length(signal)
        plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataRaw,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Raw Signal','Time (s)','Amplitude (V)',...
            parameters.saveRaw,... % save
            parameters.showRaw,... % show
            signal(i,1).path,'subplot', signal(i,1).channel);
    end
end

%% Plot rectified signal
if ~parameters.saveRectified && ~parameters.showRectified
else
    for i = 1:length(signal)
        plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataRectified,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Rectified Signal (High Pass Filtered 1 Hz)','Time (s)','Amplitude (V)',...
            parameters.saveRectified,... % save
            parameters.showRectified,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
    end
end

%% Plot differential signal
if ~parameters.saveDifferential && ~parameters.showDifferential
else
    for i = 1:length(signal)
        if isempty(signal(i,1).channelPair)
            if parameters.saveDifferential == 1 || parameters.showDifferential == 1
                warning('ChannelRef is not keyed in...')
            end
        else
            plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataDifferential,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Differential Signal Channel','Time(s)','Amplitude (V)',...
                parameters.saveDifferential,... % save
                parameters.showDifferential,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
        end
    end
end

%% Plot filtered signal
if ~parameters.saveFilt && ~parameters.showFilt
else
    if signal(i,1).dataFiltered.highPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.lowPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.notchFreq ~= 0
        for i = 1:length(signal)
            plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataFiltered.values,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Filtered Signal (', num2str(signal(i,1).dataFiltered.highPassCutoffFreq),'-', num2str(signal(i,1).dataFiltered.lowPassCutoffFreq), ')'],'Time (s)','Amplitude (V)',...
                parameters.saveFilt,... % save
                parameters.showFilt,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
        end
    end
end

%% Plot FFT signal
if ~parameters.saveFFT && ~parameters.showFFT
else
    for i = 1:length(signal)
        plotFig(signal(i,1).dataFFT.freqDomain,signal(i,1).dataFFT.values,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],[signal(i,1).dataFFT.dataBeingProcessed,' FFT Signal'],'Frequency (Hz)','Amplitude',...
            parameters.saveFFT,... % save
            parameters.showFFT,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
    end
end

%% Plot windows following stimulation artefacts
if ~parameters.saveOverlap && ~parameters.showOverlap
    windowsValues = nan;
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
        if isequal(parameters.selectedWindow, 'dataFiltered') || isequal(parameters.selectedWindow, 'dataTKEO')
            parameters.selectedWindow = [{parameters.selectedWindow};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValues, dataName] = loadMultiLayerStruct(signal(i,1),parameters.selectedWindow); % get the values and the name of the selected window
        
        maxBurstLength = max(signalClassification(i,1).burstDetection.burstEndLocs - signalClassification(i,1).burstDetection.spikeLocs,[],1);
        
        windowsValues = getPointsWithinRange(...
            signal(i,1).time/signal(i,1).samplingFreq,...
            dataValues,...
            signalClassification(i,1).burstDetection.spikeLocs,...
            signalClassification(i,1).burstDetection.spikeLocs + repmat(maxBurstLength*1.5,size(signalClassification(i,1).burstDetection.spikeLocs,1),1),...
            parameters.windowSize, signal(i,1).samplingFreq, parameters.channelExtractStartingLocs);
        
        % Get all windows in same plots
%         windowsValues.xAxisValues = reshape(windowsValues.xAxisValues,[],2*size(windowsValues.xAxisValues,2));
%         windowsValues.burst = reshape(windowsValues.burst,[],2*size(windowsValues.burst,2));
        
        % Plot overlapping windows
        plotFig(windowsValues.xAxisValues,windowsValues.burst,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Windows Following Artefacts ( ', dataName, ' )'],'Time (s)','Amplitude (V)',...
            parameters.saveOverlap,... % save
            parameters.showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair);
        
        % plot averaging overlapping windows
        plotFig(windowsValues.xAxisValues,nanmean(windowsValues.burst,2),[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Average Windows Following Artefacts ( ', dataName, ' )'],'Time(s)','Amplitude (V)',...
            parameters.saveOverlap,... % save
            parameters.showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair);
        
        % plot overall signal with spikes indicated
        if parameters.showOverlap || parameters.saveOverlap
            overallP = plotFig(signal(i,1).time/signal(i,1).samplingFreq,dataValues,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Overall Signal with Spikes Indicated (', dataName, ')'],'Time(s)','Amplitude (V)',...
                0,... % save
                1,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
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
            end
        end
    end
end
end

