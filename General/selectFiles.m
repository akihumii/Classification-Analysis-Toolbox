function varargout = selectFiles(dialogTitle, varargin)
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
if nargin > 1
    ext = varargin{1};
else
    ext = '*.*';
end

[files, path] = uigetfile(['*',ext],dialogTitle,'MultiSelect','on');
if iscell(files)
    iter = length(files);
else
    iter = 1;
    if files
        files = cellstr(files);
    else
        error('File selection is canceled...')
    end
end

files = natsortfiles(files);

varargout{1} = files;
varargout{2} = path;

if nargout == 3
    varargout{3} = iter;
end

end

