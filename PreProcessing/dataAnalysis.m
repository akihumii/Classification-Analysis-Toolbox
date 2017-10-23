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
channel = 1:2;

%% Analyse Data
for i = 1:iter
    data(i,1) = classData(files{i},path,'sylphX',channel);
    data(i,1) = filterData(data(i,1),data(i,1).dataRaw,'dataRaw',highPassCutoffFreq,lowPassCutoffFreq,data(i,1).samplingFreq);
    dataName{i,1} = data(i,1).file;
    disp([data(i,1).file, ' has been analysed... '])
end

end

