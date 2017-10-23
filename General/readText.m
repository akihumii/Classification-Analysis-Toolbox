function textContent = readText()
%readText read text file and save in variable
%   output = readText()
% [textFile, textPath] = uigetfile('*.*','Select Parameters Text File','MultiSelect','on');
textPath = 'C:\DrAmit\IntanData\Parameters\';
allFiles = dir(textPath);
allFiles = allFiles(3:end);
[~,idx] = sort([allFiles.datenum],'descend');
textFile = allFiles(idx(1)).name;

textFileName = fullfile(textPath,textFile);
textID = fopen(textFileName);
textContent = fscanf(textID,'%f');

end

