function [] = onlineClassifierTraining()
%TRAINCLASSFIIER Train the classifier with Qt codes
%   Detailed explanation goes here

%% Parameters
parameters = struct(...
    'lenDataMin',40,... % minimum samples to process
    'lenBurst',300); % length of bursts stored in memory

%% Pre-train
[signal,signalClassificationInfo] = mainClassifier(); % to detect the bursts

% analyzeFeatures(); % to train the classifier

%% Save required information for online classification
numFiles = length(signal);

for i = 1:numFiles
    thresholds = signalClassificationInfo(i,1).burstDetection.threshold;
    numStartConsecutivePoints = signalClassificationInfo(i,1).burstDetection.TKEOStartConsecutivePoints;
    numEndConsecutivePoint = signalClassificationInfo(i,1).burstDetection.TKEOEndConsecutivePoints;
    
    saveVar(fullfile(signal(i,1).path,'Info','onlineClassification'),[signal(i,1).fileName,'OnlineClassificationInfo'],...
        thresholds, numStartConsecutivePoints, numEndConsecutivePoint);
end
        

% %% stream in data
% t = tcpip('127.0.0.1',1345,'NetworkRole','client');
% fopen(t);
% 
% while (1)
%     data = fread(t,t.BytesAvailable); % store data
%     
%     if length(data) > parameters.lenDataMin
%         dataTKEO = TKEO(data);
%     end
%     
%     [peaks, locs] = triggerSpikeDetection(dataTKEO,parameters.lenBurst);
% end


end

