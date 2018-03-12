function output = combineSignal(fileType,varargin)
%combineSignal Combine multiple signals into one signal
%   input:  [files, path, iter], either input non or input 3 of them tgt
%
%   output: data:   it will be saved in the matrix [dataPoints x channel]
%           time:   it will be saved in a fat matrix
%
%   output = combineSignal(varargin)

if nargin < 2
    neutrinoBit = 1;
    neutrinoInputRefer = 1;
else
    neutrinoBit = varargin{1,1};
    neutrinoInputRefer = varargin{1,2};
end

[files, path, iter] = selectFiles(); % select files to be analysed

for i = 1:iter
    [data{i,1}, time{i,1}] = reconstructData(files{1,i}, path, fileType, neutrinoBit, neutrinoInputRefer);
end

for i = 2:iter % add time 
    time{i,1} = time{i,1} + time{i-1}(end);
end

output.file = files;
output.path = path;
output.iter = iter;
output.data = vertcat(data{:,1}); % combine the data
output.time = horzcat(time{:,1}); % combine the time
end

