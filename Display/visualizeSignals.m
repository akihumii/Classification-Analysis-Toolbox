function [] = visualizeSignals(signal, signalClassification)
%visualizeSignal Visualize needed signals
%   function [] = visualizeSignal(signal, signalClassification)

%% Plot raw signal
for i = 1:length(signal)
    samplingFreq = signal(i,1).dataFiltered.samplingFreq;
    plotFig(1/samplingFreq:1/samplingFreq:size(signal(i,1).dataRaw,1)/samplingFreq,signal(i,1).dataRaw,signal(i,1).fileName,'Raw Signal','Time(s)','Amplitude(V)',...
        'n',... % save
        'y',... % show
        signal(i,1).path,'subplot', signal.channel);
    
    clear samplingFreq
end

%% Plot filtered signal
for i = 1:length(signal)
    samplingFreq = signal(i,1).dataFiltered.samplingFreq;
    plotFig((1:size(signal(i,1).dataFiltered.values,1))/samplingFreq,signal(i,1).dataFiltered.values,signal(i,1).fileName,['Filtered Signal (', num2str(signal(i,1).dataFiltered.highPassCutoffFreq),'-', num2str(signal(i,1).dataFiltered.lowPassCutoffFreq), ')'],'Time(s)','Amplitude(V)',...
        'n',... % save
        'y',... % show
        signal(i,1).path,'subplot', signal.channel);
    
    clear samplingFreq
end

%% Plot windows following stimulation artefacts
extraTimeAddedBeforeStartLocs = 0.001; % in seconds
extraTimeAddedAfterEndLocs = 0.000; % in seconds

for i = 1:length(signalClassification)
    samplingFreq = signal(i,1).dataFiltered.samplingFreq;

%     [xAxisValues, yAxisValues] = getWindowAroundLocs(signal(i,1).dataRaw, samplingFreq, signalClassification(i,1), extraTimeAddedBeforeStartLocs, extraTimeAddedAfterEndLocs);
    windowsValues =...
        classificationWindowSelection(signal(i,1).dataFiltered.values,...
        signalClassification(i,1).burstDetection.spikeLocs,...
        [-extraTimeAddedBeforeStartLocs, signalClassification(i,1).window(2)+extraTimeAddedAfterEndLocs],...
        samplingFreq);
    
    plotFig(windowsValues.xAxisValues/samplingFreq,windowsValues.windowFollowing,signal(i,1).fileName,['Windows Following Artefacts ( ', signalClassification.selectedWindows.dataProcessed, ' )'],'Time(s)','Amplitude(V)',...
        'n',... % save
        'y',... % show
        signal(i,1).path,'overlap', signal.channel);
    
    clear xAxisValues yAxisValues samplingFreq...
        xAxisValuesEndLocs xAxisValuesStartLocs
end
end

