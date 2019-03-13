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
definput = {'50','50','30','30'};
threshMultStr = inputdlg(prompt,title,dims,definput);
threshMult = str2double(threshMultStr)';
targetSubject = 'NHP'; % inupt either 'Derek' for biceps NRF demo set; or NHP for monkey device

%% Pre-train
switch targetSubject
    case 'Derek'
        [signal,signalClassificationInfo,saveFileName,~,parameters] = mainClassifier('markBurstInAllChannels',handles.UserData.multiChannelFlag,'threshStdMult',threshMult,'showOverlap',0,'saveOverlap',0); % to detect the bursts
        
    case 'NHP'
        [signal,signalClassificationInfo,saveFileName,~,parameters] = ...
            mainClassifier('markBurstInAllChannels',handles.UserData.multiChannelFlag,...
            'burstLen',str2num(handles.inputBurstLen.String),'threshStdMult',threshMult,'showOverlap',0,'baselineType','movingWindow',...
            'saveOverlap',0,'showRaw',0,'showFilt',0,'saveRaw',0,'saveFilt',0,'saveOverlap',0,...
            'TKEOStartConsecutivePoints',[25,45,45,45],'saveUserInput',1,'padZeroFlag',0,'burstTrimming',0); % to detect the bursts
        
    otherwise
        error('Invalid input targetSubject...')
end

end

