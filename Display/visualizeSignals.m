function [] = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, saveRaw, showRaw, saveDelta, showDelta, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)
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

%% Plot rectified signal
if ~saveRectified && ~showRectified
else
    for i = 1:length(signal)
        samplingFreq = signal(i,1).dataFiltered.samplingFreq;
        plotFig(1/samplingFreq:1/samplingFreq:size(signal(i,1).dataRectified,1)/samplingFreq,signal(i,1).dataRectified,signal(i,1).fileName,'Rectified Signal (High Pass Filtered 1 Hz)','Time(s)','Amplitude(V)',...
            saveRectified,... % save
            showRectified,... % show
            signal(i,1).path,'subplot', signal.channel);
        
        clear samplingFreq
    end
end

%% Plot differential signal
if ~saveDelta && ~showDelta
else
    for i = 1:length(signal)
        if isempty(signal(i,1).channelRef)
            if saveDelta == 1 || showDelta == 1
                warning('ChannelRef is not keyed in...')
            end
        else
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

%% Plot FFT signal
if ~saveFFT && ~showFFT
else
    for i = 1:length(signal)
        plotFig(signal(i,1).dataFFT.freqDomain,signal(i,1).dataFFT.values,signal(i,1).fileName,[signal(i,1).dataFFT.dataBeingProcessed,' FFT Signal'],'Frequency(Hz)','Amplitude',...
            saveFFT,... % save
            showFFT,... % show
            signal(i,1).path,'subplot', signal.channel);
    end
end

%% Plot windows following stimulation artefacts
if ~saveOverlap && ~showOverlap
else
    windowSize(1) = -windowSize(1); 
    
    for i = 1:length(signalClassification)
        samplingFreq = signal(i,1).dataFiltered.samplingFreq;
        
        if isequal(selectedWindow, 'dataFiltered')
            selectedWindow = [{'dataFiltered'};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValues, dataName] = loadMultiLayerStruct(signal(i,1),selectedWindow); % get the values and the name of the selected window
        
        windowsValues =...
            classificationWindowSelection(dataValues,...
            signalClassification(i,1).burstDetection.spikeLocs,...
            windowSize,...
            samplingFreq);
        
        plotFig(windowsValues.xAxisValues/samplingFreq,windowsValues.windowFollowing,signal(i,1).fileName,['Windows Following Artefacts ( ', signalClassification(i,1).selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal.channel);
        
        % plot averaging overlapping windows
        plotFig(windowsValues.xAxisValues/samplingFreq,nanmean(windowsValues.windowFollowing,2),signal(i,1).fileName,['Average Windows Following Artefacts ( ', signalClassification(i,1).selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal.channel);
        
        % plot overall signal with spikes indicated
        if showOverlap
            numChannel = size(signalClassification(i,1).burstDetection.spikeLocs,2);
            overallP = plotFig((1:size(dataValues,1))/samplingFreq,dataValues,signal(i,1).fileName,['Overall Signal with Indicated Spikes ( ', dataName, ')'],'Time(s)','Amplitude(V)',...
                0,... % save
                1,... % show
                signal(i,1).path,'subplot', signal.channel);
            hold on
            for j = 1:numChannel
                axes(overallP(j,1))
                notNanSpikeLocs = ~isnan(signalClassification(i,1).burstDetection.spikeLocs(:,j)); % get locs that are non nan
                plot(signalClassification(i,1).burstDetection.spikeLocs(notNanSpikeLocs,j)/samplingFreq,dataValues(signalClassification(i,1).burstDetection.spikeLocs(notNanSpikeLocs,j),j),'ro')
                clear notNanSpikeLocs
            end
        end
        
        clear xAxisValues yAxisValues samplingFreq...
            xAxisValuesEndLocs xAxisValuesStartLocs
    end
end
end

