%% Data Filtering
% Read data then apply filtering to it.
clear
close all
clc 

ticDataAnalysis = tic;
[signal, signalName, iter] = dataAnalysis;
signal
disp([num2str(toc(ticDataAnalysis)), ' seconds used for loading and processing data...'])

clearvars -except signal signalName iter

