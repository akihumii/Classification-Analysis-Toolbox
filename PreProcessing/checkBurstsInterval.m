function [] = checkBurstsInterval(varargin)
%CHECKBURSTSINTERVAL Check the burst interval to see their actual speed.
%Only the intervals fall in between 0 to 3 seconds will be included.
% input: 'useHPC','saveMatFile','saveHistFlag','plotHistFlag','xbinsWidth'
%
%   [] = checkBurstsInterval(varargin)

close all

%% Default Parameters
parameters = struct(...
    'selectFile',1,...
    'saveMatFile',0,...
    'saveHistFlag',0,...
    'plotHistFlag',1,...
    'xbinsWidth',0.05,...
    'combineAllBursts',0);

if nargin > 0
    parameters = varIntoStruct(parameters,varargin{1,:}); % to load the varargin into structure
end

%% Load data
switch parameters.selectFile 
    case 0
        [files, path, iter] = getCurrentFiles('*.mat'); % select files in current path
    case 1
        [files, path, iter] = selectFiles('select mat files for classifier''s training'); % select files to be analysed
    case 2
        [files, path, iter] = getCurrentFiles(parameters.specificTarget);
    case 3
        splittedStr = split(parameters.specificTarget);
        files = splittedStr(end);
        path = fullfile(splittedStr(1:end-1));
        iter = 1;
    otherwise
        error('Invalid option for selectFile...')
end

%% Read and Reconstruct
disp('Processing...')

for i = 1:iters
    files{1,i} = allFiles(i,1).name;
    fileNames{i,1} = files{1,i}(1:end-4);
    signalInfo(i,1) = getFeaturesInfo(path,files{1,i});
end

%% Get bursts intervals
numChannel = size(signalInfo(1,1).signalClassification.burstDetection.spikeLocs,2);

for i = 1:iters
    burstInterval{i,1} = diff(signalInfo(i,1).signalClassification.burstDetection.spikeLocs);
    burstInterval{i,1} = vertcat(burstInterval{i,1}, nan(1,numChannel)); % for the last set of bursts
    burstInterval{i,1}(burstInterval{i,1}<0 | burstInterval{i,1}>3*signalInfo(i,1).samplingFreq) = nan;
    burstIntervalAllSeconds{i,1} = burstInterval{i,1} / signalInfo(i,1).samplingFreq;
end

%% Store and Save Burst Intervals into the .mat files
if parameters.saveMatFile
    for i = 1:iters
        fileTemp = load(allFiles(i,1).name);
        fileTemp.varargin{1,2}.burstDetection.burstInterval = burstInterval{i,1};
        fileTemp.varargin{1,2}.burstDetection.burstIntervalSeconds = burstIntervalAllSeconds{i,1};
        saveVarWithoutTime(path,allFiles(i,1).name(1:end-4),fileTemp.varargin{:});
    end
end

%% Combine all the Burst Intervals in the current directory
if parameters.combineAllBursts
    close all
    
    burstIntervalAll = vertcat(burstIntervalAllSeconds{:,1});
    titleName = 'Burst Interval Histogram';
    dataDate = vertcat(signalInfo(:,1).fileDate);
    dataSpeed = vertcat(signalInfo(:,1).fileSpeed);
    dataDateNSpeed = checkMatNAddStr([dataDate,dataSpeed],' ',1);
    dataDateNSpeed = checkMatNAddStr([dataDateNSpeed(1,1);dataDateNSpeed(end,1)],' , ',2);
    for i = 1:numChannel
        for j = 1:iters
            % Individual BI
            try
                plotFig(parameters.xbinsWidth,burstIntervalAllSeconds{j,1}(:,i),fileNames{j,1},[titleName,' channel ',num2str(i)],'Time (s)','Occurence',parameters.saveHistFlag,parameters.plotHistFlag,'','',0,'histPlot');
            catch
                warning(['channel ', num2str(i),' ', fileNames{j,1},' failed to plot ...'])
            end
        end
        % Combined BI
        BITemp = burstIntervalAll(:,i);
        try
            plotFig(parameters.xbinsWidth,burstIntervalAll(:,i),signalInfo(1,1).fileDate{1,1},[titleName, dataDateNSpeed,' channel ',num2str(i)],'Time (s)','Occurence',parameters.saveHistFlag,parameters.plotHistFlag,'','',0,'histPlot');
        catch
            warning(['channel ', num2str(i),' combined files failed to plot ...'])
        end
    end
    
end
end
