function burstTiming = deleteBurst(burstTiming, p, signalOutput, burstSectionTiming)
%deleteBurst Summary of this function goes here
%   Detailed explanation goes here
set(gcf,'units','points','position',[400,0,1050,800])

for n = 1:length(p)
    %% plot the texts on axes
    axes(p(n))
    yLimit = get(gca,'ylim');
    burstNum = size(burstTiming{n},2);
    hold on
    for i = 1:burstNum
        text((burstSectionTiming.timeStart + burstTiming{n}(1,i))/signalOutput.Fs, yLimit(1)/1e4, num2str(i));
    end
    hold off
    
    %% Input & Deleted unwanted bursts
    disp('Input unwanted bursts:')
    deletingBurst = zeros(0,1);
    deletingBurst = [deletingBurst;input('')];
    while deletingBurst(end) ~= 0
        deletingBurst = [deletingBurst;input('')];
    end
    deletingBurst(end) = [];
    
    burstTiming{n}(:,deletingBurst) = []; % Delete unwanted bursts
    
end

close

end


