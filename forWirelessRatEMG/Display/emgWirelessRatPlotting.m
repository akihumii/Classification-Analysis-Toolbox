function output = emgWirelessRatPlotting()
%EMGWIRELESSRATPLOTTING
%   Plot the rats EMG
clear
close all

Fs = 16671; %sampling rate
res = 0.000000195; %uV
channel = [1,2];
chN = 2;
Fc1 = 20;
Fc2 = 500;

% Save & Show Figures
[answerSave, answerShow] = saveAndShowQuestion();

% Allocation
settings.Fs = Fs; settings.Fc1 = Fc1; settings.Fc2 = Fc2;
settings.ch = channel; settings.chN = chN;
settings

%% Load and combine files
[files, path, iter] = selectFiles;

%% Process data
[data, time] = reconstructData(files, path, res, iter); 

%% Filter data
dataFilt = filterData(data, Fc1, Fc2, Fs, iter);

%% FFT data
[dataFFT, fqDomain] = fftDataConvert(data, Fs, iter);

%% Naming
fileName = naming(files, iter);

%% Plot data
if isequal(answerShow,'y')
    plotFig(fqDomain, dataFFT, fileName, 'Frequency Spectrum', 'Frequency(Hz)', 'DFT Values', iter, answerSave, path);
    plotFig(time, data, fileName, 'Raw Signal', 'Time(s)', 'Amplitude(\muV)', iter, answerSave, path);
    plotFig(time, dataFilt, fileName, 'Filtered Signal', 'Time(s)', 'Amplitude(\muV)', iter, answerSave, path);
end

%%
output.raw = data;
output.filtered = dataFilt;
output.FFT = dataFFT;
output.time = time;
output.fqDomain = fqDomain;
output.fileName = fileName;
output.path = path;
output.iter = iter;
output.Fs = Fs;

disp('Finished')
end

