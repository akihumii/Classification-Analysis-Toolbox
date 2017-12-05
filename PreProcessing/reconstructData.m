function [data, time] = reconstructData(files, path, fileType, neutrinoInputRefer)
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
        data(:,1:10) = data(:,1:10)*res; % convert data to Voltage, keep the counter and sync pulse unchanged
        
        time = 1:size(data,1);
        
    case 'intan'
        %% For Intan
        [data, time, samplingFreq] = readIntan([path,files]);
        data = data*res;
        data = data'; % make it into structure of [samplePoint x channels]
        time = time*samplingFreq;
        
    case 'neutrino'
        %% For Neutrino
        data = csvread([path,files]); % read the csv file into variable data
        data = 1.2*data/1024; % convert to Voltage
        time = 1:size(data,1); 
        
    case 'neutrino2'
        %% For Neutrino with bit analysing function
        [data,~,~] = xlsread([path,files]);
        info = data(2,4); % info for multiplicatoin
        bitInfo = bitget(info,5:8); % convert info into binary for comparison
        bitInfo = fliplr(bitInfo); % flip the array
        gain = inputReferMultiplier(bitInfo); % compute the gain
        data = data(3:end,1:end); % raw data before multiplication
        if neutrinoInputRefer == 1
            data = gain * data; % change output refer data into input refer data
        end
        time = 1:size(data,1);
        
end
end

