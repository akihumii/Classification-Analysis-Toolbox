function [newValues, newLocs] = pointAfterAWindow(data,window,locs)
%pointAfterWindow Get the valus and the locations after a certain window.
%Ignore the ones that exceed the data limit.
%   Detailed explanation goes here

numLocs = length(locs);

if numLocs == 0 || isnan(locs(1,1))
    newLocs = nan;
    newValues = nan;
else
    newLocs = locs + repmat(window,size(locs));
    newValues = data(newLocs);
end

end

