function [] = saveVar(path,fileName,varargin)
%saveVar Save the variables in the folder 'Info' appended with saving time
%   [] = saveVar(path,fileName,varargin)

if ~exist(path,'file')
    mkdir(path);
end

timeString = time2string;

save([path,fileName,' ',timeString],'varargin');

end

