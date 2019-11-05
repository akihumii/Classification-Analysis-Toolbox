function h = plotFillStd(x, data)
%PLOTFILLSTD Plot 3*std filled lines
% input:    x is the 1-D array of index of the data
%           data is the raw data for doing std. Columns are observations.
%   Detailed explanation goes here
m = mean(data,2);
s = std(data,[],2);
h = fill([x(:); flipud(x(:))], [m-s; flipud(m+s)], [.9, .9, .9],...
    'LineStyle', 'none', 'FaceAlpha', 0.5); 

end

