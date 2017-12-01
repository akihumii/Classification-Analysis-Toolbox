function dataFilt = filterData(data, Fc1, Fc2, Fs, iter)
%filterData Summary of this function goes here
%   enter 0 if that particular filter is not applied.

%% Built Filter
if Fc1~=0 && Fc2~=0
    [bHigh,aHigh] = butter(4,Fc1/(Fs/2),'high');
    [bLow,aLow] = butter(4,Fc2/(Fs/2),'low');    
    for i = 1:iter
        dataHPF(:,i) = filtfilt(bHigh,aHigh,data(:,i));
        dataBPF(:,i) = filtfilt(bLow,aLow,dataHPF(:,i));
    end
    
elseif Fc1==0
    [bLow,aLow] = butter(4,Fc2/(Fs/2),'low');
    for i = 1:iter
        dataBPF(:,i) = filtfilt(bLow,aLow,data(:,i));
    end
    
elseif Fc2==0
    [bHigh,aHigh] = butter(4,Fc1/(Fs/2),'high');
    for i = 1:iter
        dataBPF(:,i) = filtfilt(bHigh,aHigh,data(:,i));
    end
end

dataFilt = dataBPF;

end

