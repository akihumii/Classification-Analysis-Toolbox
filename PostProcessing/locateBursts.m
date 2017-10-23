function timing = locateBursts(data,burstTiming,baselineTiming,baselineParam,Fs,iter)
%locateBursts Summary of this function goes here
%   Detailed explanation goes here
data_burst = data(burstTiming.timeStart:burstTiming.timeEnd,:);
data_burst_absolute = abs(data_burst);
data_baseline = data(baselineTiming.timeStart:baselineTiming.timeEnd,:);
data_baseline_absolute = abs(data_baseline);

%% Filter data
[numRawDataPoint, numChannel] = size(data_burst,1);
for n = 1:numChannel
    data_burst_filtered = filterData(data_burst(:,n));
    data_burst_absolute_filtered = filterData(data_burst_absolute(:,n));
    data_baseline_filtered = filterData(data_baseline(:,n));
    data_baseline_absolute_filtered = filterData(data_baseline_absolute(:,n));
end

%% Teager-Kaiser Energy Operator(TKEO)
dataTKEO = TKEO(data_burst,Fs,iter);

[numTKEODataPoint, numChannel] = size(dataTKEO,1);
timing = cell(iter,1);

for n = 1:numChannel
    startingPoint = zeros(0,1);
    endPoint = zeros(0,1);
    threshold = baselineParam.mean(n) + 3*baselineParam.std(n);

    for i = 1:numTKEODataPoint-25
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

%% Approximated generalized likelihood-step (AGL-step)
% logLikelihoodRatioOutput = likelihoodRatioTest(data_burst_absolute_filtered, data_baseline_absolute_filtered, 1);

%% k-Means (KM)
% k = 5; % number of cluster based on a-priori decision
% kMeansOutput = kMeansConverter(data_burst_absolute_filtered, k);
% 
% baselineClass =  find(kMeansOutput.meanDistanceWithinClass == ...
%     min(kMeansOutput.meanDistanceWithinClass));
% baselineIndex = kMeansOutput.idx(kMeansOutput.idx == baselineClass); 

end

