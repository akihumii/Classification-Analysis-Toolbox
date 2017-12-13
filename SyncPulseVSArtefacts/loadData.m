function extractedData = loadData(type)
%LOADSYLPHX Load and output data.
% 
% input: type: 'tdms' or 'csv'
% 
%   extractedData = loadData(type)
[fullFileName, pathname] = uigetfile('*.*','select data file','MultiSelect','on');
if iscell(fullFileName)
    iter = length(fullFileName);
else
    iter = 1;
    fullFileName = cellstr(fullFileName);
end
tic
for j = 1:iter
    name = fullFileName{j};
    disp('Loading...')
    switch type
        case 'csv'
            extractedData.data = dlmread([pathname name]);
        case 'tdms'
            extractedData.data = convertTDMS(0,[pathname name]);
            toc
            extractedData.data = stackData(extractedData.data.Data.MeasuredData);
    end
end
extractedData.size = size(extractedData.data);

end