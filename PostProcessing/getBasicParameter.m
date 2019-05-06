function output = getBasicParameter(data)
%basicParam Output the basic parameters, input must be vertical array.
%
% output: mean, std, stde, max, min
%
%   output = getBasicParameter(data)

if isnumeric(data)
    average = squeeze(mean(data,1));
    standardDeviation = squeeze(std(data,0,1));
    stde = squeeze(standardDeviation/sqrt(size(data,1)));
    [maxValue,maxLoc] = max(data,[],1);
    maxValue = squeeze(maxValue);
    Loc = squeeze(maxLoc);
    [minValue,minLoc] = min(data,[],1);
    minValue = squeeze(minValue);
    minLoc = squeeze(minLoc);
    raw = data;
else
    average = nan;
    standardDeviation = nan;
    stde = nan;
    maxValue = nan;
    Loc = nan;
    minValue = nan;
    minLoc = nan;
    raw = nan;
end

%% output
output = makeStruct(...
    average,...
    standardDeviation,...
    stde,...
    maxValue,...
    Loc,...
    minValue,...
    minLoc,...
    raw);
end

