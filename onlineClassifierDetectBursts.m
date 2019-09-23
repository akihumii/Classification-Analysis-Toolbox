function [threshMultStr, signal, signalClassificationInfo, saveFileName, parameters] = onlineClassifierDetectBursts(handles)
%ONLINECLASSIFIERDETECTBURSTS Have some more options to alter the burst
%detection algorithm used in mainClassifier.
%
%   [threshMultStr, signal, signalClassificationInfo, saveFileName] = onlineClassifierDetectBursts()

% put 'warning('query','all')' in ClassificationECOC>localFitECOC/loopBody

%% input threshold multiplier
prompt = {'Channel 1:','Channel 2:','Channel 3:','Channel 4:'};
title = 'Input threshold multiplier';
dims = [1 35];
% definput = {'190','180','95','60'};
% definput = {'10','10','10','10'};
definput = string(repmat(50,4,1));
threshMultStr = inputdlg(prompt,title,dims,definput);
threshMult = str2double(threshMultStr)';
targetSubject = 'NHP'; % inupt either 'Derek' for biceps NRF demo set; or NHP for monkey device

%% Pre-train
if handles.TKEOmoreBox.Value
    spikeDetectionType = 'TKEOmore';
else
    spikeDetectionType = 'TKEO';
end

switch targetSubject
    case 'Derek'
        [signal,signalClassificationInfo,saveFileName,~,parameters] = mainClassifier('markBurstInAllChannels',handles.UserData.multiChannelFlag,'threshStdMult',threshMult,'showOverlap',0,'saveOverlap',0); % to detect the bursts
        
    case 'NHP'
        [signal,signalClassificationInfo,saveFileName,~,parameters] = ...
            mainClassifier('dataType','raw','channel',4:7,'channelAveragingFlag',0,'selectFile',1,...
            'highPassCutoffFreq',0,'lowPassCutoffFreq',0,'getBaselineFeatureFlag',~handles.UserData.multiChannelFlag,...
            'overlappedWindow','dataRaw','dataThresholdOmitFlag',0,'restoreSyncPulseFlag',0,'dataPeriodicOmitFrequency',0,...
            'threshold',0,'markBurstInAllChannels',handles.UserData.multiChannelFlag,'makeFirstFileBaseline',handles.UserData.multiChannelFlag,...
            'burstLen',str2num(handles.inputWindowSize.String)/1000,'threshStdMult',threshMult,'showOverlap',0,'baselineType','movingWindow',...
            'showSyncPulse',0,'showCounter',0,'showOverlap',0,'showRaw',0,'showFilt',0,'showRaster',0,'saveRaster',0,'saveRaw',0,'saveFilt',0,'saveOverlap',0,'showCompare',0,'saveCompare',0,...
            'datathresholdOmitFlag',0,'dataToBeDetectedSpike','dataTKEO',...
            'optimizeTKEOFlag',handles.optimizeBox.Value,'featuresID',handles.UserData.featuresID,...
            'spikeDetectionType',spikeDetectionType,'stepWindowSize',0.05,...
            'deltaLossLimit', 5e-4,'lossLimit',1e-3,'learningRate',[10,10,5],...
            'partialDataSelection',0,'TKEOStartConsecutivePoints',[25,45,45,45],'TKEOEndConsecutivePoints',[60],'saveUserInput',1,'padZeroFlag',0,...
            'burstTrimming',handles.burstTrimmingBox.Value,'burstTrimmingType',1); % to detect the bursts
        
    otherwise
        error('Invalid input targetSubject...')
end

end

