function [data, timeIndex] = reconstructData(files, path, fileType, neutrinoBit, neutrinoInputRefer)
%reconstructData Reconstruct different formats of data
% 
% fileType: 'sylphii' 'sylphx' 'intan' 'neutrino' 'neutrino2'
% neutrinoBit: 1 for 8 bit mode, 0 for 10 bit mode
% neutrinoInputRefer: 1 for checking input refer, 0 for checking output
% 
%   [data, xAxisIndex] = reconstructData(files, path, fileType, neutrinoBit, neutrinoInputRefer)

res = 0.000000195; %V/unit

if nargin < 4
    neutrinoBit = 1;
    neutrinoInputRefer = 1;
end

switch lower(fileType)
    case 'sylphii'
        %% For wireless Rat EMG (Pinching Test)
        for i = 1:length(files)
            dataTemp = csvread(fullfile(path, files{i}));
            dataTemp = dataTemp';
            data(:,i) = dataTemp(:)*res; % convert to Voltage
            
            timeIndex = transpose(1:size(data,1));
        end
        
    case 'sylphx'
        %% For EMG Wireless Newest Format
%         dataLength = length(dlmread(fullfile(path,files),',',[0,0,-1,0]));
%         numParts = 10;
%         parts = floor(0:dataLength/10:dataLength-1);
%         partId = 2;
%         data = dlmread(fullfile(path,files),',',[parts(partId),0,parts(partId+3),12]);
        data = csvread(fullfile(path,files));
        numTotalChannel = 10;
        data(:,1:numTotalChannel) = data(:,1:numTotalChannel)*res; % convert data to Voltage, keep the counter and sync pulse unchanged

        timeIndex = transpose(1:size(data,1));
        
    case 'raw'
        data = csvread(fullfile(path,files),1,0);
        
        timeIndex = transpose(1:size(data,1));
        
    case 'intan'
        %% For Intan
        [data, timeIndex, samplingFreq] = readIntan(fullfile(path,files));
        data = data*res;
        data = data'; % make it into structure of [samplePoint x channels]
        timeIndex = transpose(timeIndex*samplingFreq);
        
    case 'intanraw'
        [data, timeIndex, samplingFreq] = readIntan(fullfile(path,files));
        data = data'; % make it into structure of [samplePoint x channels]
        timeIndex = transpose(timeIndex*samplingFreq);
        
    case 'neutrino'
        %% For Neutrino
        data = csvread(fullfile(path,files)); % read the csv file into variable data
        if neutrinoBit
            convertVoltage = 1.2/256;
        else
            convertVoltage = 1.2/1024;
        end
        data = data * convertVoltage; % convert to Voltage
        timeIndex = transpose(1:size(data,1)); 
        
    case 'neutrino2'
        %% For Neutrino with bit analysing function
        info = dlmread(fullfile(path,files),',',[0,1,1,7]); % info for multiplicatoin
        info = info(2,3);
        bitInfo = bitget(info,5:8); % convert info into binary for comparison
        bitInfo = fliplr(bitInfo); % flip the array
        gain = inputReferMultiplier(bitInfo); % compute the gain
        data = dlmread(fullfile(path,files),',',2,0);
        if neutrinoInputRefer == 1
            data = data / gain; % change output refer data into input refer data
        end
        
        if neutrinoBit
            convertVoltage = 1.2/256;
        else
            convertVoltage = 1.2/1024;
        end
        data(:,1:10) = data(:,1:10) * convertVoltage; % convert to Voltage

        timeIndex = transpose(1:size(data,1));
        
end
end

