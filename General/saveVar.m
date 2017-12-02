function [] = saveVar(path,fileName,varargin)
%saveVar Save the variables in the folder 'Info' appended with saving time
%   [] = saveVar(path,fileName,varargin)

saveLocation = [path,'Info\'];

if ~exist(saveLocation,'file')
    mkdir(saveLocation);
end

currentTime = mat2str(clock);
currentTime = currentTime(2:end-6);
save([saveLocation,fileName,' ',currentTime],'varargin');

end

