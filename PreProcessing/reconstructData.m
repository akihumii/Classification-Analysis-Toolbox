function [data, time] = reconstructData(files, path, fileType, neutrinoBit, neutrinoInputRefer)
%reconstructData Reconstruct different formats of data
% 
% fileType: 'sylphii' 'sylphx' 'intan' 'neutrino' 'neutrino2'
% neutrinoBit: 1 for 8 bit mode, 0 for 10 bit mode
% neutrinoInputRefer: 1 for checking input refer, 0 for checking output
% 
%   [data, time] = reconstructData(files, path, fileType, neutrinoBit, neutrinoInputRefer)

res = 0.000000195; % V/unit
% res = 0.00195;
% res = 2/1024; % 

if nargin < 4
    neutrinoBit = 1;
    neutrinoInputRefer = 1;
end

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

        % edit the lousy data
        data = editData(data,data(:,11),[0,255],2);
        time = 1:size(data,1);
        
    case 'odin'
        %% For converting voltage recorded from force sensor into Newton
        data = csvread([path,files]);
        data(:,1:10) = res*data(:,1:10);
        data(:,1:10) = 56.4087.*(data(:,1:10))/1000*9.8;
%         data(:,1:10) = ((-34.776*(data(:,1:10).*data(:,1:10))+84.9*data(:,1:10)+0.113))/1000*9.8; % convert Voltage into Newton, keep the counter and sync pulse unchanged

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
        if neutrinoBit
            convertVoltage = 1.2/256;
        else
            convertVoltage = 1.2/1024;
        end
        data = data * convertVoltage; % convert to Voltage
        time = 1:size(data,1); 
        
    case 'neutrino2'
        %% For Neutrino with bit analysing function
        info = dlmread([path,files],',',[0,1,1,7]); % info for multiplicatoin
        info = info(2,3);
        bitInfo = bitget(info,5:8); % convert info into binary for comparison
        bitInfo = fliplr(bitInfo); % flip the array
        gain = inputReferMultiplier(bitInfo); % compute the gain
        data = dlmread([path,files],',',2,0);
        if neutrinoInputRefer == 1
            data = data / gain; % change output refer data into input refer data
        end
        
        if neutrinoBit
            convertVoltage = 1.2/256;
        else
            convertVoltage = 1.2/1024;
        end
        data = data * convertVoltage; % convert to Voltage

        time = 1:size(data,1);
        
end
end

