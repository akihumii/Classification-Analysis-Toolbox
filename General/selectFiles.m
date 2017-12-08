function varargout = selectFiles()
%selectFiles Select files and output its path and name
%   varargout = selectFiles()
% 
% varargout{1} = files (compulsory)
% varargout{2} = path (compulsory)
% varargout{3} = iter (optional)

[files, path] = uigetfile('*.*','select decoding file','MultiSelect','on');
if iscell(files)
    iter = length(files);
else
    iter = 1;
    files = cellstr(files);
end

varargout{1} = files;
varargout{2} = path;

if nargout == 3
    varargout{3} = iter;
end

end

