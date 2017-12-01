function [data, time] = reconstructData(files, path, res, iter)
%reconstructData Summary of this function goes here
%   Detailed explanation goes here

%% For wireless Rat EMG (Pinching Test)
% for i = 1:iter
%     dataTemp = csvread([path, files{i}]);
%     dataTemp = dataTemp';
%     data(:,i) = dataTemp(:)*res;
% end
% 
% time = 1:size(data,1);

%% For Dr. Amit

for i = 1:iter
    dataTemp = csvread([path,files{i}]);
    data(:,i) = dataTemp(:,i)*res;
end
 
time = 1:size(data,1);

end

