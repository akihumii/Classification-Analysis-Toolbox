function output = classificationWindowSelection(data, epochLocs, windowSize, Fs)
%classificationWindowSelection Summary of this function goes here
%   Detailed explanation goes here

sampleSize = windowSize * Fs;
blankWindowSize = 1.5 * Fs; % ms * unit/ms

[rowData, colData] = size(data);

for i = 1:colData
    for j = 1:length(epochLocs{i})
        windowClassOne{i,1}(:,j) = ...
            data(epochLocs{i}(j) + blankWindowSize : epochLocs{i}(j) + sampleSize + blankWindowSize, i);
        
        windowClassTwo{i,1}(:,j) = ...
            data(epochLocs{i}(j) - sampleSize - blankWindowSize : epochLocs{i}(j) - blankWindowSize, i);
    end
end

output.windowClassOne = windowClassOne;
output.windowClassTwo = windowClassTwo;

end

