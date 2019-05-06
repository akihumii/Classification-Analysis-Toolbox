function [data] = separateAccuracy(dataAll,numChannel,iters)
%separateAccuracy Separate all the accuracies into different channels and
%number of feature used in classification
%   [data] = separateAccuracy(dataAll,numChannel,iters)
for i = 1:numChannel
    % initiate
    data{i,1} = zeros(0,numChannel);
    for j = 1:iters
        data{i,1} = horzcat(data{i,1}, dataAll{j,1}(:,i));
    end
    data{i,1} = transpose(data{i,1});
end
end

