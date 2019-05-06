function varargout = saveVar(path,fileName,varargin)
%saveVar Save the variables in the folder 'Info' appended with saving time
% 
% output: varargout: saveDir, varargin
% 
%   [] = saveVar(path,fileName,varargin)

if ~exist(path,'file')
    mkdir(path);
end

timeString = time2string;

saveDir = fullfile(path,[fileName,'_',timeString,'.mat']);
save(saveDir,'varargin');
disp(['Saved matfile ',saveDir]);

if nargout >= 1
    varargout{1,1} = saveDir;
    if nargout >= 2
        varargout{1,2} = varargin;
    end
end

end

