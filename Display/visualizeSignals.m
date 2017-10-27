function [] = visualizeSignals(signal, signalClassification, selectedWindow, saveRaw, showRaw, saveDelta, showDelta, saveFilt, showFilt, saveOverlap, showOverlap)
%visualizeSignal Visualize needed signals. Raw, filtered, differential,
%overlapping windows, average windows, and overall signal with indicated
%spikes can be plotted.
% Average window will be show/save according to the input of
% 'showOverlap/saveOverlap'.
% Overall signal with indicated spikes will be show only when the input 
% 'showOverlap' is 1 and will not be saved.
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
    if signal(i,1).dataFiltered.highPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.lowPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.notchFreq ~= 0
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
        
        plotFig(windowsValues.xAxisValues/samplingFreq,windowsValues.windowFollowing,signal(i,1).fileName,['Windows Following Artefacts ( ', signalClassification(i,1).selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal.channel);
        
        % plot averaging overlapping windows
        plotFig(windowsValues.xAxisValues/samplingFreq,mean(windowsValues.windowFollowing,2),signal(i,1).fileName,['Average Windows Following Artefacts ( ', signalClassification(i,1).selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal.channel);
        
        % plot overall signal with spikes indicated
        if showOverlap
            plotFig((1:size(dataValues,1))/samplingFreq,dataValues,signal(i,1).fileName,['Overall Signal with Indicated Spikes ( ', dataName, ')'],'Time(s)','Amplitude(V)',...
                0,... % save
                1,... % show
                signal(i,1).path,'subplot', signal.channel);
            hold on
            plot(signalClassification(i,1).burstDetection.spikeLocs/samplingFreq,dataValues(signalClassification(i,1).burstDetection.spikeLocs),'ro')
        end
        
        clear xAxisValues yAxisValues samplingFreq...
            xAxisValuesEndLocs xAxisValuesStartLocs
    end
end
end

