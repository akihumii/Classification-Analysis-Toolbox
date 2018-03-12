function windowsValues = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)
%visualizeSignal Visualize needed signals. Raw, filtered, differential,
%overlapping windows, average windows, and overall signal with indicated
%spikes can be plotted.
% Average window will be show/save according to the input of
% 'showOverlap/saveOverlap'.
% Overall signal with spikes indicated will be show only when the input
% 'showOverlap' is 1 and will not be saved.
%   [] = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, saveRaw, showRaw, saveDelta, showDelta, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)

%% Partial Data Selectiom
if partialDataSelection
    partialDataStartingTime = [' (',num2str(signal.time(1) / signal.samplingFreq)];
    partialDataEndTime = [' - ', num2str(signal.time(end) / signal.samplingFreq), ' s) '];
else
    partialDataStartingTime = '';
    partialDataEndTime = '';
end

%% Plot raw signal
if ~saveRaw && ~showRaw
else
    plotFig(signal.time/signal.samplingFreq,signal.dataRaw,[signal.fileName,partialDataStartingTime,partialDataEndTime],'Raw Signal','Time(s)','Amplitude(V)',...
        saveRaw,... % save
        showRaw,... % show
        signal.path,'subplot', signal.channel);
end

%% Plot rectified signal
if ~saveRectified && ~showRectified
else
    plotFig(signal.time/signal.samplingFreq,signal.dataRectified,[signal.fileName,partialDataStartingTime,partialDataEndTime],'Rectified Signal (High Pass Filtered 1 Hz)','Time(s)','Amplitude(V)',...
        saveRectified,... % save
        showRectified,... % show
        signal.path,'subplot', signal.channelPair);
end

%% Plot differential signal
if ~saveDifferential && ~showDifferential
else
    if isempty(signal.channelPair)
        if saveDifferential == 1 || showDifferential == 1
            warning('ChannelRef is not keyed in...')
        end
    else
        plotFig(signal.time/signal.samplingFreq,signal.dataDifferential,[signal.fileName,partialDataStartingTime,partialDataEndTime],'Differential Signal Channel','Time(s)','Amplitude(V)',...
            saveDifferential,... % save
            showDifferential,... % show
            signal.path,'subplot', signal.channelPair);
    end
end

%% Plot filtered signal
if ~saveFilt && ~showFilt
else
    if signal.dataFiltered.highPassCutoffFreq ~= 0 || signal.dataFiltered.lowPassCutoffFreq ~= 0 || signal.dataFiltered.notchFreq ~= 0
        plotFig(signal.time/signal.samplingFreq,signal.dataFiltered.values,[signal.fileName,partialDataStartingTime,partialDataEndTime],['Filtered Signal (', num2str(signal.dataFiltered.highPassCutoffFreq),'-', num2str(signal.dataFiltered.lowPassCutoffFreq), ')'],'Time(s)','Amplitude(V)',...
            saveFilt,... % save
            showFilt,... % show
            signal.path,'subplot', signal.channelPair);
    end
end

%% Plot FFT signal
if ~saveFFT && ~showFFT
else
    plotFig(signal.dataFFT.freqDomain,signal.dataFFT.values,[signal.fileName,partialDataStartingTime,partialDataEndTime],[signal.dataFFT.dataBeingProcessed,' FFT Signal'],'Frequency(Hz)','Amplitude',...
        saveFFT,... % save
        showFFT,... % show
        signal.path,'subplot', signal.channelPair);
end

%% Plot windows following stimulation artefacts
if ~saveOverlap && ~showOverlap
else
    %% Plot the data for peak detection
    if isequal(dataToBeDetectedSpike, 'dataFiltered') || isequal(dataToBeDetectedSpike, 'dataTKEO')
        dataToBeDetectedSpike = [{dataToBeDetectedSpike};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
    end
    
    [dataValuesPeakDetection, dataNamePeakDetection] = loadMultiLayerStruct(signal,dataToBeDetectedSpike);
    
    numChannel = size(signalClassification.burstDetection.spikeLocs,2);
    overallP = plotFig(signal.time/signal.samplingFreq,dataValuesPeakDetection,[signal.fileName,partialDataStartingTime,partialDataEndTime],['Signal used for Peak Detection (', dataNamePeakDetection, ')'],'Time(s)','Amplitude(V)',...
        0,... % save
        1,... % show
        signal.path,'subplot', signal.channelPair);
    hold on
    
    % Plot the markings
    for j = 1:numChannel
        plotMarkings(overallP(j,1), signal.time/signal.samplingFreq, dataValuesPeakDetection(:,j), signalClassification.burstDetection.spikeLocs(:,j), signalClassification.burstDetection.burstEndLocs(:,j), signalClassification.burstDetection.threshold(j,1))
    end
    
    %% Plot Overlapping Signals
    if isequal(selectedWindow, 'dataFiltered') || isequal(selectedWindow, 'dataTKEO')
        selectedWindow = [{selectedWindow};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
    end
    
    [dataValues, dataName] = loadMultiLayerStruct(signal,selectedWindow); % get the values and the name of the selected window
    
    maxBurstLength = max(signalClassification.burstDetection.burstEndLocs - signalClassification.burstDetection.spikeLocs,[],1);
    
    windowsValues = getPointsWithinRange(...
        signal.time/signal.samplingFreq,...
        dataValues,...
        signalClassification.burstDetection.spikeLocs,...
        signalClassification.burstDetection.spikeLocs + repmat(maxBurstLength,size(signalClassification.burstDetection.spikeLocs,1),1),...
        windowSize, signal.samplingFreq, channelExtractStartingLocs);
    
    % Get all windows in same plots
    %         windowsValues.xAxisValues = reshape(windowsValues.xAxisValues,[],2*size(windowsValues.xAxisValues,2));
    %         windowsValues.burst = reshape(windowsValues.burst,[],2*size(windowsValues.burst,2));
    
    % Plot overlapping windows
    plotFig(windowsValues.xAxisValues,windowsValues.burst,[signal.fileName,partialDataStartingTime,partialDataEndTime],['Windows Following Artefacts ( ', dataName, ' )'],'Time(s)','Amplitude(V)',...
        saveOverlap,... % save
        showOverlap,... % show
        signal.path,'overlap', signal.channelPair);
    
    % plot averaging overlapping windows
    plotFig(windowsValues.xAxisValues,nanmean(windowsValues.burst,2),[signal.fileName,partialDataStartingTime,partialDataEndTime],['Average Windows Following Artefacts ( ', dataName, ' )'],'Time(s)','Amplitude(V)',...
        saveOverlap,... % save
        showOverlap,... % show
        signal.path,'overlap', signal.channelPair);
    
    % plot overall signal with spikes indicated
    if showOverlap || saveOverlap
        overallP = plotFig(signal.time/signal.samplingFreq,dataValues,[signal.fileName,partialDataStartingTime,partialDataEndTime],['Overall Signal with Spikes Indicated (', dataName, ')'],'Time(s)','Amplitude(V)',...
            0,... % save
            1,... % show
            signal.path,'subplot', signal.channelPair);
        hold on
        
        % Plot the markings
        for j = 1:numChannel
            plotMarkings(overallP(j,1), signal.time/signal.samplingFreq, dataValues(:,j), signalClassification.burstDetection.spikeLocs(:,j), signalClassification.burstDetection.burstEndLocs(:,j), nan)
        end
        
        % Save
        if saveOverlap
            savePlot(signal.path,['Overall Signal with Spikes Indicated (', dataName, ')'],[signal.fileName,partialDataStartingTime,partialDataEndTime],[signal.fileName,partialDataStartingTime,partialDataEndTime])
        end
        if ~showOverlap
            close gcf
        end
    end
end
end

