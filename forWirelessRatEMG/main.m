%% main code for EMG analysis
% including plotting figures, saving figures, selecting partial signals
% locating starting point and end point
% feature extraction
% classification

clear
close all
clc

signalOutput = emgWirelessRatPlotting;

close all

%% select partial signals
plotFig(1:size(signalOutput.filtered,1),signalOutput.filtered,signalOutput.fileName,'','','',signalOutput.iter,'',signalOutput.path);
baselineSectionTiming = selectPartial(); % part of signal that is set as baseline
baselineParameter = basicParameter(signalOutput.filtered(baselineSectionTiming.timeStart:baselineSectionTiming.timeEnd,:));

plotFig(1:size(signalOutput.filtered,1),signalOutput.filtered,signalOutput.fileName,'','','',signalOutput.iter,'',signalOutput.path);
burstSectionTiming = selectPartial(); % part of signal that contains the bursts that are going to be analysed

close 

%% locate starting point and end point of bursts
burstTiming = locateBursts(signalOutput.filtered,burstSectionTiming,baselineParameter,signalOutput.Fs,signalOutput.iter); % timing of starting point & end point of each burst

%% locate spike timing
spikeTiming = detectSpikes(signalOutput.filtered);

%% Classification
windowSize = 20; % ms
windowsClassification = classificationWindowSelection(signalOutput.filtered, spikeTiming.spikeLocs, windowSize, signalOutput.Fs);

% For analysing windows before and after spikes
for i = 1:signalOutput.iter
    features{i}.classOne = featureExtraction(windowsClassification.windowClassOne{i});
    features{i}.classTwo = featureExtraction(windowsClassification.windowClassTwo{i});
    
    classificationOutput{i} = classification(features{i});
end

% For analysing windows from two different currents

%% Temporarily save the windows
saveName = 'current 2';
save(saveName,'features');

%% Run Classification
featureClassOne = load('current 1');
featureClassTwo = load('current 2');
features.classOne = featureClassOne.features{1}.classOne;
features.classTwo = featureClassTwo.features{1}.classOne;

classificationOutput = classification(features);
performance = mean(classificationOutput.class{1,1})
const = classificationOutput.coefficient{1,1}(1,2).const
linear =  classificationOutput.coefficient{1,1}(1,2).linear

%% Plot overall signal & Delete unwanted bursts
repeat = 'y';
while isequal(repeat,'y')
    fig = plotSignalsWithLines(signalOutput, burstTiming, burstSectionTiming); % plot with all the bursts
    burstTiming = deleteBurst(burstTiming, fig, signalOutput, burstSectionTiming); % updated burst Timing with unwanted bursts
    
    plotSignalsWithLines(signalOutput, burstTiming, burstSectionTiming); % updated plot without unwanted bursts
    set(gcf,'units','points','position',[400,0,1050,800]) % to avoid blocking of windows
    repeat = input('Delete more bursts? (y/n): ','s');
end

disp('Finished cleaning the bursts. Press any key to continue.');
pause
close

%% obtain bursts signals
% first layer sorts in trials
% second layer sorts in bursts
for n = 1:signalOutput.iter
    for i = 1:size(burstTiming{n},2)
        dataBurst{n,1}{i,1} = signalOutput.filtered(burstTiming{n}(1,i):burstTiming{n}(2,i),n); % signals of each burst assign into different cells
    end
end

%% analyse
for i = 1:signalOutput.iter
    zParam{i} = zScore(dataBurst{i},baselineParameter,i); % features of each burst, sorts in trials in first layer
end

%% save
save([signalOutput.path,signalOutput.fileName{1}(1:end-3),' info'],'baselineParam',...
    'baselineSectionTiming','burstSectionTiming','burstTiming','dataBurst','signalOutput',...
    'zParam');

disp('Finished.');
