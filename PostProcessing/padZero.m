function [] = padZero(file)
%padZero Read the file and pad zeros at skipping point and save as csvfile at filePath
%
%   [] = padZero(file)

%  Coded by Tsai Chne Wuen

close all

popMsg('Upper limit of the counter: 65535');

%% Parameters
channelCounter = 12;
notDiffValue = [1,-65535]; % correct counter difference

popMsg('Processing...'); % pop the message box to show processing...

%% Read and analyze counter
data = reconstructData(file,'','sylphx'); % read and reconstruct the data

[rowData,colData] = size(data);

counterInfo = analyseContValue(data(:,channelCounter),notDiffValue); % analyse counter

%% Pad zero
newData = data(1:counterInfo.skipDataLocs(1),:); % pad data before the first skipping location
newData = [newData;zeros(counterInfo.skipDataArray(1)-1,colData)]; % pad zero for first skipped value
padLocs = transpose(counterInfo.skipDataLocs(1)+1 : counterInfo.skipDataArray(1)-1); % obtain the locations which are padded with zero

count = 2; % index number of skipping point

for i = counterInfo.skipDataArray(1)+1:rowData
    if count > counterInfo.numSkipData
        break
    else
        if i == counterInfo.skipDataLocs(count)
            newData = [newData;data(counterInfo.skipDataLocs(count-1)+1:i,:)];
            newData = [newData;zeros(counterInfo.skipDataArray(count)-1,colData)];
            padLocs = [padLocs;transpose(i+1:i+counterInfo.skipDataArray(count)-1)];
            count = count + 1;
        end
    end
end

newData = [newData;data(i:end,:)]; % pad remaining data

%% Save new data padded with zeros
newFileName = [file(1:end-4),' data padded with zeros.csv']; % file name of data padded with zeros
csvwrite(newFileName,newData); % save new data

popMsg('Finished all the process...'); % pop up a message box to show the end of the code

end

