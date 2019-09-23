function [] = trimData()
%TRIMDATA Trim the data and save it.
%   [] = trimData()

%% input parameters
prompt = {'sampling freq:'};
title = 'Input parameters';
dims = [1 35];
definput = {'1250'};
threshMultStr = inputdlg(prompt,title,dims,definput);
samplingFreq = str2double(threshMultStr)';

%% select files
[files, path] = selectFiles('Select file...');
if length(files) == 1
    [data, time] = reconstructData(files{1,1}, path, 'raw');
else
    errordlg('Choose one fiel only!');
end

%% trim data


end

