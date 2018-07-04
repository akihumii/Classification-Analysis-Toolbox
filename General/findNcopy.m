function allFiles = findNcopy(fileFormat)
%FINDNCOPY Find the target file format and copy to a folder
% input:    fileFormat: Target file format to copy
% output:   allFiles: Storing the found file name, path, date, bytes, isdir, datenum
%
%   allFiles = findNcopy()

matlabVersion = version;
matlabVersion = str2double(matlabVersion(end-5:end-1));

if  matlabVersion >= 2016
    
    cwd = pwd;
    
    [files] = uigetdir('Select the folders for searching');
    
    [targetFiles] = uigetdir('','Select the folders for saving the copied files');
    
    cd(files)
    allFiles = dir(['**/*.',fileFormat]);
    cd(cwd);
    
    numFiles = length(allFiles);
    for i = 1:numFiles
        copyfile(fullfile(allFiles(i,1).folder,allFiles(i,1).name),targetFiles);
    end
    
else
    %% Recursive method
    fileFormat = ['*', fileFormat]; % select all of the files that have the target format
    
    [files] = uigetdir('Select the folders for searching');
    
    [targetFiles] = uigetdir('','Select the folders for saving the copied files');
    
    allfiles = dir(files);
    
    copyAllFiles(allfiles,targetFiles,fileFormat); % copy all the files including subfolders
    
end
end

function copyAllFiles(allfiles,targetFiles,fileFormat)

allfiles = allfiles(3:end); % delete the current folder and parent directories
numFiles = length(allfiles);

if any(vertcat(allfiles(:).isdir))
    for i = 1:numFiles
        if allfiles(i,1).isdir
            copyAllFiles(dir(fullfile(allfiles(i,1).folder,allfiles(i,1).name)),targetFiles,fileFormat);
        end
    end
else
    try
        copyfile(fullfile(allfiles(1,1).folder,fileFormat),targetFiles);
    catch
        warning(['no matching files were found in ', allfiles(1,1).folder, '...'])
    end
end
end



