function [] = padZero(file)
%padZero Read the file and pad zeros at skipping point and save as csvfile at filePath
%
%   [] = padZero(file)

%  Coded by Tsai Chne Wuen

if nargin == 0 % if no file is input then user will need to select the files to be analyzed
    [files,path,iter] = selectFiles();
else
    iter = 1;
end

close all

popMsg('Upper limit of the counter: 65535');

%% Parameters
channelCounter = 12;
notDiffValue = [1,-65535]; % correct counter difference

popMsg('Processing...'); % pop the message box to show processing...

%% Read and analyze counter
for i = 1:iter
    
    if nargin == 0
        file = [path,files{i,1}];
    end
    
    data = reconstructData(file,'','sylphx'); % read and reconstruct the data
    
    [rowData,colData] = size(data);
    
    counterInfo = analyseContValue(data(:,channelCounter),notDiffValue); % analyse counter
    
    %% Pad zero
    newData = data(1:counterInfo.skipDataLocs(1),:); % pad data before the first skipping location
    if counterInfo.numSkipData > 1 && diff(counterInfo.skipDataLocs(1:2))==1
        newData = [newData;zeros(1,colData)];
        padLocs = counterInfo.skipDataLocs(1)+1;
    else
        newData = [newData;zeros(counterInfo.skipDataArray(1)-1,colData)]; % pad zero for first skipped value
        padLocs = transpose(counterInfo.skipDataLocs(1)+1 : counterInfo.skipDataArray(1)-1); % obtain the locations which are padded with zero
    end
    
    count = 2; % index number of skipping point
    
    figure
    
    for i = counterInfo.skipDataArray(1)+1:rowData
        if count > counterInfo.numSkipData % exclude the last one in case the last one is also the glitch and it can't be detected in the following algorithm
            break
        else
            if i == counterInfo.skipDataLocs(count)
                if diff(counterInfo.skipDataLocs(count-1:count))==1 % if it's glitch, i.e. the diff between the previous one and this one is 1, pad one zero
                    newData = [newData;zeros(1,colData)];
                    padLocs = [padLocs;i+1];
                else
                    newData = [newData;data(counterInfo.skipDataLocs(count-1)+1:i,:)]; % if it's not a glitch, pad zero with the number of the distance between the previous skipped data location until this iteration
                    newData = [newData;zeros(counterInfo.skipDataArray(count)-1,colData)];
                    padLocs = [padLocs;transpose(i+1:i+counterInfo.skipDataArray(count)-1)];
                end
                count = count + 1;
            end
        end
    end
    newData = [newData;data(i:end,:)]; % pad remaining data
    
    plot(newData(:,12))
    axis tight
    
    %% Save new data padded with zeros
    newFileName = [file(1:end-4),' data padded with zeros.csv']; % file name of data padded with zeros
    csvwrite(newFileName,newData); % save new data
    
end

popMsg('Finished all the process...'); % pop up a message box to show the end of the code

end
