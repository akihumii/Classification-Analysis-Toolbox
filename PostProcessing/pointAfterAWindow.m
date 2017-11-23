function [newValues, newLocs] = pointAfterAWindow(data,window,locs)
%pointAfterWindow Get the valus and the locations after a certain window
%   [newValues, newLocs] = pointAfterAWindow(data,window,locs)

numLocs = length(locs);

for i = 1:numLocs
    newLocs(i,1) = locs(i) + window;
    newValues(i,1) = data(locs(i) + window);
end

end

