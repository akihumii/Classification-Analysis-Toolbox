function [data, time] = reconstructData(files, path, fileType)
%reconstructData Summary of this function goes here
%   Detailed explanation goes here
res = 0.000000195; %uV/unit

switch lower(fileType)
    case 'sylphii'
        %% For wireless Rat EMG (Pinching Test)
        for i = 1:length(files)
            dataTemp = csvread([path, files{i}]);
            dataTemp = dataTemp';
            data(:,i) = dataTemp(:)*res; % convert to Voltage
            
            time = 1:size(data,1);
        end
        
    case 'sylphx'
        %% For EMG Wireless Newest Format
        data = csvread([path,files]);
        data = data*res; % convert to Voltage
        
        time = 1:size(data,1);
        
    case 'intan'
        %% For Intan
        [data, time] = readIntan([path,files]);
        data = data*res;
        
    case 'neutrino'
        %% For Neutrino
        data = csvread([path,files]); % read the csv file into variable data
        data = 1.2*data/1024; % convert to Voltage
        time = 1:size(data,1); 
        
    case 'neutrino2'
        %% For Neutrino with bit analysing function
        [data,~,~] = xlsread([path,files]);
        info = data(2,4); % info for multiplicatoin
        bitInfo = bitget(info,3:8); % convert info into binary for comparison
        data = data(3:end,1:end); % raw data before multiplication
        time = 1:size(data,1);
        
end
end

