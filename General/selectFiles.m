function [files, path, iter] = selectFiles()
%selectFiles Select files and output its path and name
%   [files, path, iter] = selectFiles()

[files, path] = uigetfile('*.*','select decoding file','MultiSelect','on');
if iscell(files)
    iter = length(files);
else
    iter = 1;
    files = cellstr(files);
end
end

