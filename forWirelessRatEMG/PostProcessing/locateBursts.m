function timing = locateBursts(data,burstTiming,baselineParam,Fs,iter)
%locateBursts Summary of this function goes here
%   Detailed explanation goes here
data_burst = data(burstTiming.timeStart:burstTiming.timeEnd,:);

%% get TKEO data
dataTKEO = TKEO(data_burst,Fs,iter);

%% get starting point and end point
[rowData, colData] = size(dataTKEO);
timing = cell(iter,1);

for n = 1:colData
    startingPoint = zeros(0,1);
    endPoint = zeros(0,1);
    threshold = baselineParam.mean(n) + 3*baselineParam.std(n);

    for i = 1:rowData-25
        if length(startingPoint) == length(endPoint)
            if dataTKEO(i:i+25,n) > threshold
                startingPoint = [startingPoint,i];
            end
        else
            if dataTKEO(i:i+25,n) < threshold
                endPoint = [endPoint,i];
            end
        end
    end
    timing{n,1} = [startingPoint;endPoint];
end

end

