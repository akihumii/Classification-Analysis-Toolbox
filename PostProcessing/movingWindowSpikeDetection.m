function output = movingWindowSpikeDetection(data, lag, threshold, influence)
%MOVINGWINDOWSPIKEDETECTION Use the moving window technique to get the
%baseline and spikes
% input: lag:       window size
%        threshold: number to multiply to standard deviation of window data
%        influence: 0 to 1, as the influence of the spike to the basleine
%                   window data
%   output = movingWindowSpikeDetection(data, lag, threshold, influence)

signals = zeros(size(data));
filter_data = data;
filter_avg = zeros(size(data));
filter_std = zeros(size(data));
filter_avg(lag-1) = mean(data(1:lag));
filter_std(lag-1) = std(data(1:lag));

for i = lag+1 : length(data)
    if abs(data(i) - filter_avg(i-1)) > threshold * filter_std(i-1)
        if data(i) > filter_avg(i-1)
            signals(i) = 1;
        else
            signals(i) = -1;
        end
        
        filter_data(i) = influence * data(i) + (1-influence) * filter_data(i-1);
        filter_avg(i) = mean(filter_data((i-lag) : i));
        filter_std(i) = std(filter_data((i-lag) : i));
    else
        signals(i) = 0;
        filter_data(i) = data(i);
        filter_avg(i) = mean(filter_data((i-lag) : i));
        filter_std(i) = std(filter_data((i-lag) : i));
    end
end

baseline = data(~signals);
baseline_std = std(baseline);

output = makeStruct(...
    signals,...
    filter_avg,...
    filter_std,...
    baseline,...
    baseline_std);
end

