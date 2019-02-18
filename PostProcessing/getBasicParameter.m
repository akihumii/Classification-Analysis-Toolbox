function output = getBasicParameter(data)
%basicParam Output the basic parameters, input must be vertical array.
%
% output: mean, std, stde, max, min
%
%   output = getBasicParameter(data)

if isnumeric(data)
    average = squeeze(nanmean(data,1));
    stD = squeeze(nanstd(data,0,1));
    stde = squeeze(stD/sqrt(size(data(~isnan(data)),1)));
    [maxValue,maxLoc] = max(data,[],1);
    maxValue = squeeze(maxValue);
    Loc = squeeze(maxLoc);
    [minValue,minLoc] = min(data,[],1);
    minValue = squeeze(minValue);
    minLoc = squeeze(minLoc);
    array = data;
else
    average = nan;
    stD = nan;
    stde = nan;
    maxValue = nan;
    Loc = nan;
    minValue = nan;
    minLoc = nan;
    array = nan;
end

%% output
output = makeStruct(...
    average,...
    stD,...
    stde,...
    maxValue,...
    Loc,...
    minValue,...
    minLoc,...
    array);
end

