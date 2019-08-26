function [] = plotOptimization()
%PLOTOPTIMIZATION Plot the graph of TKEO optimization.
%   Detailed explanation goes here
[files, path] = selectFiles('Select info mat file that has TKEO information');

info = load(fullfile(path, files{1,1}));

figure
for i = 1:5
    p(i,1) = subplot(5,1,i);
    hold on
    grid on
    grid minor
end

axes(p(1,1))
for i = 1:4
    plot(info.varargin{1, 4}.objOptimize.TKEOParametersChange.TKEOStartConsecutivePoints(:,i),'-s','linewidth',3)
    title('TKEOStartConsecutivePoints')
end

axes(p(2,1))
for i = 1:4
    plot(info.varargin{1, 4}.objOptimize.TKEOParametersChange.TKEOEndConsecutivePoints(:,i),'-V','linewidth',3)
    title('TKEOEndConsecutivePoints')
end

axes(p(3,1))
for i = 1:4
    plot(info.varargin{1, 4}.objOptimize.TKEOParametersChange.threshStdMult(:,i),'-*','linewidth',3)
    title('threshStdMult')
end

axes(p(4,1))
plot(info.varargin{1, 4}.objOptimize.TKEOParametersChange.loss,'linewidth',3)
title('loss')

axes(p(5,1))
plot(info.varargin{1, 4}.objOptimize.TKEOParametersChange.deltaLoss,'linewidth',3)
title('delta loss')

linkaxes(p, 'x');
end

