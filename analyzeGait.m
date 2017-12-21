%% Read Gait and Plot Starting and End Lines of Stance Phase
% It requires readGait and plotGait functions to run.
% Open the figure that have the bursts plotted before running this script.
clear
close all
clc

%% User Input
saveFigure = 0;
showFigure = 1;

%% Main
[gaitLocs,gaitFilePath] = readGait;

display('Finished reading gaits...')
display(' ')

plotGait(gaitLocs,saveFigure,showFigure,gaitFilePath);

finishMsg()
