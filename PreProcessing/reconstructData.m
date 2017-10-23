function [data, time, channel] = reconstructData(files, path, fileType)
%reconstructData Summary of this function goes here
%   Detailed explanation goes here
res = 0.000000195; %uV/unit

switch lower(fileType)
    case 'sylphii'
        %% For wireless Rat EMG (Pinching Test)
        for i = 1:length(files)
            dataTemp = csvread([path, files{i}]);
            dataTemp = dataTemp';
            data(:,i) = dataTemp(:)*res;
            
            time = 1:size(data,1);
        end
        
        channel = 1:length(files);
        
    case 'sylphx'
        %% For EMG Wireless Newest Format
        dataTemp = csvread([path,files]);
        channel = 1:2;
        numChannel = length(channel);
        for j = 1:numChannel
            data(:,j) = dataTemp(:,j)*res;
        end
        
        time = 1:size(data,1);
        
    case 'intan'
        %% For Intan
        [dataTemp, time] = readIntan([path,files]);
        channel = 39;
        numChannel = length(channel);
        for j = 1:numChannel
            data(:,j) = dataTemp(channel(j),:)*res;
        end
        
        %% obtain differential signal
        % data = dataDifferentialSubtraction(data, 3);
end
end

