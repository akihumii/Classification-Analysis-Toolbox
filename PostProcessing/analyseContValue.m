function output = analyseContValue(data,notDiffValue)
%analyseNotContValue Analyze continuous value like Counter
% 
% input:    notDiffValue: an array of values that are supposed to be the
% differences 
% 
%   output = analyseContValue(data,notDiffValue)

diffData = diff(data);

correctData = ismember(diffData,notDiffValue);

skipDataLogics = ~correctData;

skipDataLocs = find(skipDataLogics==1);

skipDataArray = diffData(skipDataLocs);

numSkipData = length(skipDataLocs);

%% Plot
figure
histogram(skipDataArray,numSkipData); % plot number of occurence

figure
hold on
plot(data); % plot counter
plot(skipDataLocs,data(skipDataLocs),'ro'); % plot skipping point

output.skipDataArray = skipDataArray; 
output.skipDataLocs = skipDataLocs;
output.numSkipData = numSkipData;

end

