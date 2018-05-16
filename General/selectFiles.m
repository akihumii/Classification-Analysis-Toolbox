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
    try
        files = cellstr(files);
    catch
        error('No file was selected...');
    end
end

varargout{1} = files;
varargout{2} = path;

if nargout == 3
    varargout{3} = iter;
end

end

