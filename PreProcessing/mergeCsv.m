function [] = mergeCsv()
%MERGECSV Merge Csv files vertically
%   [] = mergeCsv()
skipLine = 1;
[files, path] = selectFiles('Select csv files to merge');

savefile = uiputfile('*.csv');

fidSave = fopen(savefile, 'w');

numFiles = length(files);

for i = 1:numFiles
    popMsg(sprintf('Processing file %d...', i));
    fidTemp = fopen(fullfile(path, files{1,i}),'r');
    lineTemp = fgets(fidTemp);
    for j = 1 : skipLine
        if ~ischar(lineTemp)
            break
        end
        lineTemp = fgets(fidTemp);
    end
    
    while ischar(lineTemp)
        fwrite(fidSave, lineTemp);
        lineTemp = fgets(fidTemp);
    end
    fclose(fidTemp);
end

fclose(fidSave);

popMsg('Finished...');
end

