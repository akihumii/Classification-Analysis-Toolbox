%% Load figures and get info from them.
% Firstly, run the section 'initialization' one time.
% Then, run the section 'load data' one time for every figure that you want to plot. 
% Thirdly, run the section 'Plotting'
% 
% input:    plotType:   'ROC', 'percentile'

%% Initialization
clear 
close all

data = cell(0,1);
titleName = cell(0,1);

%% load data
p = gca;
data = [data; p.Children.Data(~isnan(p.Children.Data))];
titleName = [titleName; p.Title.String];

%% PreProcessing
parameters = struct(...
    'plotType','percentile',...
    'overlapPerc',[20,80]);

numData = length(data);

%% PostProcessing
switch parameters.plotType
    case 'ROC'
        ROCOutput = plotROCNCheck(data,numData);
    case 'percentile'
        percOuptut = getPercentileOverlap(parameters.overlapPerc,data,numData);
    otherwise
        warning('Invalid plotType...')
end




