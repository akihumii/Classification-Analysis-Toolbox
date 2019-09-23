function output = readNeutrino(varargin)
%READNEUTRINO Read Neutrino data and plot data upon request. Data will be
%saved in the structure 'output' in Matlab Workspace.
% 
% Created on 2 July 2019 by Tsai Chne-Wuen.
% 
% Input: 'inputReferData': 1 (default) to activate input refer, vice versa.
%        'neutrinoBit':    10 (default) for 10-bit, 8 for 8-bit mode.
%        'plotFlag':       1 (defualt) for plotting raw data, vice versa.
%        'channel':        default is all, otherwise input channel as array
%                          for plotting.
% 
% Output: files, data, timeIndex, parameters, samplingFreq, p, parameters.
% 
% example:
% output = readNeutrino()  % read and plot data
% output = readNeutrino('neutrinoBit', 8)  % read as 8-bit mode and plot
% output = readNeutrino('plotFlag', 0)  % read data without plotting
% output = readNeutrino('channel', [4,5,6,7])  % read and plot channel 4, 5, 6, 7

%% Parameters and file selection
parameters = struct(...
    'inputReferData', 1,...  % 1 to activate input refer, 0 to disactivate
    'neutrinoBit', 10,...  % 8 for 8-bit mode, 10 for 10-bit mode
    'plotFlag', 1,...  % 1 to plot raw data, vice and versa
    'channel', []);  % select channels to plot

parameters = varIntoStruct(parameters, varargin);  % load the input variables into parameters

[files, path, iter] = selectFiles();  % select files to be analyzed

samplingFreq = 3e6/14/12;  % sampling frequency

%% read data
data = cell(iter,1);
timeIndex = cell(iter,1);
for i = 1:iter
    [data{i,1}, timeIndex{i,1}] = readNeutrinoFile(path, files{1,i}, parameters);
end

%% plot data
p = cell(iter,1);
if parameters.plotFlag
    for i = 1:iter
        p{i,1} = plotNeutrinoData(data{i,1}, timeIndex{i,1}, files{1,i}, samplingFreq, parameters);
    end
end

%% parse the data into the structure 'output'
output = makeStruct(files, data, timeIndex, parameters, samplingFreq, p, parameters);
    
end

function varargout = selectFiles(dialogTitle)
%selectFiles Select files and output its path and name
%   varargout = selectFiles(dialogTitle)
% 
% input: dialogTitle(optional): title of the dialog to select the file(s).
% Default is 'select decoding file'.
% 
% varargout{1} = files (compulsory)
% varargout{2} = path (compulsory)
% varargout{3} = iter (optional)

if nargin < 1
    dialogTitle = 'select decoding file';
end

[files, path] = uigetfile('*.*',dialogTitle,'MultiSelect','on');
if iscell(files)
    iter = length(files);
else
    iter = 1;
    if files
        files = cellstr(files);
    else
        error('File selection is canceled...')
    end
end

varargout{1} = files;
varargout{2} = path;

if nargout == 3
    varargout{3} = iter;
end

end

function [data, timeIndex] = readNeutrinoFile(path, files, parameters)
%% For Neutrino with bit analysing function
inputRefereData = true;  % activate input refer
neutrinoBit = 10;  % 8 for 8-bit mode, 10 for 10-bit mode

info = dlmread(fullfile(path,files),',',[0,1,1,7]); % info for multiplicatoin
info = info(2,3);
bitInfo = bitget(info,5:8); % convert info into binary for comparison
bitInfo = fliplr(bitInfo); % flip the array
gain = inputReferMultiplier(bitInfo); % compute the gain
data = dlmread(fullfile(path,files),',',2,0);

if parameters.inputReferData
    data = data / gain; % change output refer data into input refer data
end

switch parameters.neutrinoBit
    case 8
        convertVoltage = 1.2/256;  % 8-bit mode
    case 10
        convertVoltage = 1.2/1024;  % 10-bit mode
    otherwise
        error('Invalid nuetrino bit...');
end

data(:,1:10) = data(:,1:10) * convertVoltage; % convert to Voltage

timeIndex = transpose(1:size(data,1));
end

function gain = inputReferMultiplier(bitInfo)
%inputReferMultiplier Compute the multiplier based on the default table
%   gain = inputReferMultiplier(bitInfo)

R = 1047.13;

S1 = bitInfo(1);
S2 = bitInfo(3:4);

if S1 == 1
    D1 = 4;
else
    D1 = 1;
end

if isequal(S2,[0,0])
    D2 = 1;
elseif isequal(S2,[0,1])
    D2 = 1.95;
elseif isequal(S2,[1,0])
    D2 = 2.85;
elseif isequal(S2,[1,1])
    D2 = 1/5.4325;
end

gain = R / (D1 * D2);
end

function p = plotNeutrinoData(data, timeIndex, filename, samplingFreq, parameters)
p = figure;
hold on
if isempty(parameters.channel)
    numChannel = 10;
    channel = 1:10;
else
    numChannel = length(parameters.channel);
    channel = parameters.channel;
end

for i = 1:numChannel
    subplot(numChannel, 1, i);
    plot(timeIndex/samplingFreq, data(:,channel(i)));
    title(sprintf('%s channel %d', filename, channel(i)));

    if parameters.inputReferData
        ylabel('Amplitude (V)')
    else
        ylabel('Amplitude')
    end
end

linkaxes(p.Children);

xlabel('Time (s)')
end

function output = varIntoStruct(structure,varargin)
%VARINTOSTRUCT Insert variables into the strucutre.
%   output = varIntoStruct(structure,varargin)

output = structure;

if ~isempty(varargin{1,1})
    for i = 1:2:length(varargin{1,1})-1
        if ismember(varargin{1,1}{1,i},fieldnames(structure))
            fieldName = varargin{1,1}{1,i};
            fieldValue = varargin{1,1}{1,i+1};
            output.(fieldName) = fieldValue;
        end
    end
end

end