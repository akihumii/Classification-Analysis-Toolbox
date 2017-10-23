function p = plotSignalsWithLines(signalOutput,burstTiming, burstSectionTiming)
%plotSignalsWithLines Summary of this function goes here
%   Detailed explanation goes here
p = plotFig(1/signalOutput.Fs:1/signalOutput.Fs:size(signalOutput.filtered,1)/signalOutput.Fs,signalOutput.filtered,signalOutput.fileName,'','','',signalOutput.iter,'',signalOutput.path);

yLimit = get(gca,'ylim');
for n = 1:signalOutput.iter
    xTiming{n,1} = (burstTiming{n} + burstSectionTiming.timeStart)/signalOutput.Fs; % convert starting point from sample to seconds
    axes(p(n)); % point to one of the subplots that is going to be drawn the lines on it
    hold on
    for i = 1:size(xTiming{n},2)
        plot([xTiming{n}(1,i),xTiming{n}(1,i)],yLimit,'r-'); % line of starting point
        plot([xTiming{n}(2,i),xTiming{n}(2,i)],yLimit,'g-'); % line of end point
    end
    hold off
end


end

