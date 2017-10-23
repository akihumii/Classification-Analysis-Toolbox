function output = classificationWindowSelection(data,epochLocs,window,samplingFreq)
%classificationWindowSelection Output windows following the artefacts and
%windows before the artefacts, x axis values for plotting 
%   output = classificationWindowSelection(data,epochLocs,window,samplingFreq)

window = window * samplingFreq; % unit

epochLocs = checkingWindowAroundEpoch(data, epochLocs, window);

[rowLocs, colLocs] = size(epochLocs);

for i = 1:colLocs % different channel
    rowLocsNotNan = sum(~isnan(epochLocs(:,i))); % neglect NaN rows
    for k = 1:rowLocsNotNan % different windows
        windowFollowing{i,1}(:,k) = ...
            data(floor(epochLocs(k,i) + window(1)) : floor(epochLocs(k,i) + window(2)), i);
        
        windowAhead{i,1}(:,k) = ...
            data(floor(epochLocs(k,i) - window(2)) : floor(epochLocs(k,i) - window(1)), i);
    end
end

xAxisValues = window(1) : window(2);

windowFollowing = cell2nanMat(windowFollowing);
windowAhead = cell2nanMat(windowAhead);

output.windowFollowing = windowFollowing;
output.windowAhead = windowAhead;
output.xAxisValues = xAxisValues;

end

