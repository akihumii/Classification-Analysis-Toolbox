function [] = visualizeSignals(signal, signalClassification, selectedWindow, saveRaw, showRaw, saveDelta, showDelta, saveFilt, showFilt, saveOverlap, showOverlap)
%visualizeSignal Visualize needed signals
%   function [] = visualizeSignal(signal, signalClassification)

%% Plot raw signal
if ~saveRaw && ~showRaw
else
    for i = 1:length(signal)
        samplingFreq = signal(i,1).dataFiltered.samplingFreq;
        plotFig(1/samplingFreq:1/samplingFreq:size(signal(i,1).dataRaw,1)/samplingFreq,signal(i,1).dataRaw,signal(i,1).fileName,'Raw Signal','Time(s)','Amplitude(V)',...
            saveRaw,... % save
            showRaw,... % show
            signal(i,1).path,'subplot', signal.channel);
        
        clear samplingFreq
    end
end

%% Plot differential signal
if ~saveDelta && ~showDelta
else
    if isempty(signal.channelRef)
        if saveDelta == 1 || showDelta == 1
            warning('ChannelRef is not keyed in...')
        end
    else
        for i = 1:length(signal)
            samplingFreq = signal(i,1).dataFiltered.samplingFreq;
            plotFig(1/samplingFreq:1/samplingFreq:size(signal(i,1).dataDelta,1)/samplingFreq,signal(i,1).dataDelta,signal(i,1).fileName,'Differential Signal','Time(s)','Amplitude(V)',...
                saveDelta,... % save
                showDelta,... % show
                signal(i,1).path,'subplot', signal.channel);
            
            clear samplingFreq
        end
    end
end

%% Plot filtered signal
if ~saveFilt && ~showFilt
else
    if signal.dataFiltered.highPassCutoffFreq ~= 0 || signal.dataFiltered.lowPassCutoffFreq ~= 0 || signal.dataFiltered.notchFreq ~= 0
        for i = 1:length(signal)
            samplingFreq = signal(i,1).dataFiltered.samplingFreq;
            plotFig((1:size(signal(i,1).dataFiltered.values,1))/samplingFreq,signal(i,1).dataFiltered.values,signal(i,1).fileName,['Filtered Signal (', num2str(signal(i,1).dataFiltered.highPassCutoffFreq),'-', num2str(signal(i,1).dataFiltered.lowPassCutoffFreq), ')'],'Time(s)','Amplitude(V)',...
                saveFilt,... % save
                showFilt,... % show
                signal(i,1).path,'subplot', signal.channel);
            
            clear samplingFreq
        end
    end
end

%% Plot windows following stimulation artefacts
if ~saveOverlap && ~showOverlap
else
    extraTimeAddedBeforeStartLocs = 0.002; % in seconds
    extraTimeAddedAfterEndLocs = 0.000; % in seconds
    
    for i = 1:length(signalClassification)
        samplingFreq = signal(i,1).dataFiltered.samplingFreq;
        
        if isequal(selectedWindow, 'dataFiltered')
            selectedWindow = [{'dataFiltered'};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValues, dataName] = loadMultiLayerStruct(signal(i,1),selectedWindow); % get the values and the name of the selected window
        
        windowsValues =...
            classificationWindowSelection(dataValues,...
            signalClassification(i,1).burstDetection.spikeLocs,...
            [-extraTimeAddedBeforeStartLocs, signalClassification(i,1).window(2)+extraTimeAddedAfterEndLocs],...
            samplingFreq);
        
        plotFig(windowsValues.xAxisValues/samplingFreq,windowsValues.windowFollowing,signal(i,1).fileName,['Windows Following Artefacts ( ', signalClassification.selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal.channel);
        
        clear xAxisValues yAxisValues samplingFreq...
            xAxisValuesEndLocs xAxisValuesStartLocs
    end
end
end

