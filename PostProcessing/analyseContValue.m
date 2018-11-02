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

skipDataArray = diffData(skipDataLocs) - 1;

numSkipData = length(skipDataLocs);

%% Plot
pH = figure;
histogram(skipDataArray,numSkipData); % plot number of occurence

pC = figure;
hold on
plot(data); % plot counter
plot(skipDataLocs,data(skipDataLocs),'ro'); % plot skipping point

%% Output
output = makeStruct(skipDataArray,skipDataLocs,numSkipData,pH,pC);

end

