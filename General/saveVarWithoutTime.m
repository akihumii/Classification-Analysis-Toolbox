function saveDir = saveVarWithoutTime(path,fileName,varargin)
%saveVar Save the variables in the folder 'Info' appended with saving time
%   [] = saveVar(path,fileName,varargin)

if ~exist(path,'file')
    mkdir(path);
end

saveDir = fullfile(path,[fileName,'.mat']);
save(saveDir,'varargin');

end

