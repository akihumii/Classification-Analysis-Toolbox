function varargout = plotHist(data,xbinsWidth)
%PLOTHIST Plot the histogram of data
%   Detailed explanation goes here

figure;
xbinsTemp = min(data) : xbinsWidth : max(data);

p = histogram(data,xbinsTemp);

if nargin > 0
    varargout{1,1} = p;
end

end

