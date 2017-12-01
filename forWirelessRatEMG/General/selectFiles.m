function [files, path, iter] = selectFiles()
%selectFiles Summary of this function goes here
%   Detailed explanation goes here

[files, path] = uigetfile('*.*','select decoding file','MultiSelect','on');
if iscell(files)
    iter = length(files);
else
    iter = 1;
    files = cellstr(files);
end

end

