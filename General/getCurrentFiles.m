function [files, path, varargout] = getCurrentFiles(varargin)
%GETCURRENTFILES Get the files in current directory
%   [files, path, varargout] = getCurrentFiles(varargin)

if nargin == 1
    filesInfo = dir(varargin{1,1});
else
    filesInfo = dir;
end

numFiles = length(filesInfo);

for i = 1:numFiles
    files{1,i} = filesInfo(i,1).name;
end

path = [pwd,filesep];

if nargout > 2
    varargout{1,1} = numFiles;
end

end

