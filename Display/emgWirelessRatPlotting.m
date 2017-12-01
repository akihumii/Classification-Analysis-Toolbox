function output = emgWirelessRatPlotting()
%EMGWIRELESSRATPLOTTING
%   Plot the rats EMG
clear
close all

Fs = 30000; %sampling rate
lowCutoffFreq = 5;
highCutoffFreq = 3500;

% Save & Show Figures
% [answerSave, answerShow] = saveAndShowQuestion();
answerSave = 'n';
answerShow = 'y';

% Allocation
settings.Fs = Fs; settings.Fc1 = lowCutoffFreq; settings.Fc2 = highCutoffFreq;
settings

%% Load and combine files
[files, path, iter] = selectFiles;

% For preset path etc
% iter = 2;
% path = 'C:\DrAmit\IntanData\TrainingData\';
% allFiles = dir(path);
% for i = 3:4
%     files{i-2} = allFiles(i).name;
% end

%% Process data
for i = 1:iter
    [data{i,1}, time{i,1}] = reconstructData(files{1,i}, path, 'sylphX');
    
    %% Filter data
    dataFilt{i,1} = filterData(data{i,1}, lowCutoffFreq, highCutoffFreq, Fs);
    
    %% FFT data
    [dataFFT{i,1}, fqDomain{i,1}] = fftDataConvert(data{i,1}, Fs);
    
    %% TKEO
%     dataTKEO{i,1} = TKEO(data{i,1}, Fs);
    
    %% PCA
%     dataPCA{i,1} = pcaConverter(data{i,1});
    
    %% Naming
    fileName{i,1} = naming(files{1,i});
    
    %% Noise Level Detection
    noiseData = noiseLevelDetection(data{i,1});
    
    %% Plot data
    if isequal(answerShow,'y') || isequal(answerSave,'y')
        plotFig(fqDomain{i,1}, dataFFT{i,1}, fileName{i,1}, 'Frequency Spectrum', 'Frequency(Hz)', 'DFT Values', answerSave, answerShow, path, 'subplot');
        plotFig(time{i,1}, data{i,1}, fileName{i,1}, 'Raw Signal', 'Time(s)', 'Amplitude(\muV)', answerSave, answerShow, path, 'subplot');
        plotFig(time{i,1}, dataFilt{i,1}, fileName{i,1}, 'Filtered Signal', 'Time(s)', 'Amplitude(\muV)', answerSave, answerShow, path, 'subplot');
    end
    
end



%%
output.raw = data;
output.filtered = dataFilt;
output.FFT = dataFFT;
% output.dataTKEO = dataTKEO;
output.time = time;
% output.fqDomain = fqDomain;
output.fileName = fileName;
output.path = path;
output.iter = iter;
output.Fs = Fs;

disp('Finished')
end

