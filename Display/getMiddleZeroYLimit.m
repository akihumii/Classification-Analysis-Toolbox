function output = getMiddleZeroYLimit(yLimit)
%getMiddleZeroYLimit Output the new ylimit after moving zero to middle
%   output = getMiddleZeroYLimit(yLimit)
maxYLimit = max(abs(yLimit));
output = [-maxYLimit, maxYLimit];
end

