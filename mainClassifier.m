%% main code for EMG analysis
% including plotting figures, saving figures, selecting partial signals
% locating starting point and end point
% feature extraction
% classification

clear
close all
clc

ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis;
signal
disp([num2str(toc(ticDataAnalysis)), ' seconds used for loading and processing data...'])

clearvars -except signal signalName iter

%% Locate bursts and select windows around them
tic
signalClassification = dataClassificationPreparation(signal, iter)
disp([num2str(toc),' seconds used for classification preparation...'])

%% Plot selected windows
close all

tic
visualizeSignals(signal, signalClassification);
disp ([num2str(toc), ' seconds used for visualizing signals...'])


%% Run Classification
classifier = runClassification('lda',signalClassification)

% classificationOutput = classification(features);
% 
% for i = 1:length(classificationOutput.accuracy)
%     accuracy(i,1) = classificationOutput.accuracy{1,i}.accuracy;
%     const(i,1) = classificationOutput.coefficient{1,i}(1,2).const;
%     linear(i,1) = classificationOutput.coefficient{1,i}(1,2).linear;
% end
% 
% %% Run SVM
% svmOuput = svmClassify(classificationOutput.grouping);
% 
% %% Save file as .txt
% saveText(accuracy,const,linear,classificationOutput.channelPair, spikeTiming.threshold, windowSize);

display('Everything''s finshied...')


