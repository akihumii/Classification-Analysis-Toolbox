function [data, dataName, iter] = dataAnalysis()
%dataAnalysis Generate objects that describes each processed data
%   [data, dataName, iter] = dataAnalysis()
clear
close all

[files, path, iter] = selectFiles(); % select files to be analysed

%% pre-allocation
data(iter,1) = classData; % pre-allocate object array
dataName = cell(iter,1);

%% Parameters
highPassCutoffFreq = 500;
lowPassCutoffFreq = 3000;
notchFreq = 50;
channel = 1:3;
channelRef = 1;

%% Analyse Data
for i = 1:iter
    data(i,1) = classData(files{i},path,'Neutrino',channel);
    data(i,1) = filterData(data(i,1),'dataRaw', data(i,1).samplingFreq, highPassCutoffFreq,lowPassCutoffFreq, notchFreq);
    data(i,1) = dataDifferentialSubtraction(data(i,1),'dataRaw',channelRef);
    dataName{i,1} = data(i,1).file;
    disp([data(i,1).file, ' has been analysed... '])
end

end

