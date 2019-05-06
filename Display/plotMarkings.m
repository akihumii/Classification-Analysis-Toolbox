function [] = plotMarkings(handle,time,dataValues,startingLocs,endLocs,threshold)
%plotMarkings Plot starting point, end point, baseline
%   [] = plotMarkings(handle,time,dataValues,startingLocs,endLocs,threshold)
axes(handle);

hold on

%% Starting Point
notNanSpikeLocs = ~isnan(startingLocs); % get start locs that are not nan
startingO = plot(time(startingLocs(notNanSpikeLocs)),dataValues(startingLocs(notNanSpikeLocs)),'ro');

%% Text Underneath
% for k = 1:sum(notNanSpikeLocs)
%     text(startingLocs(k)/samplingFreq,baseline,num2str(k))
% end

%% End Point
% notNanEndLocs = ~isnan(endLocs); % get end locs that are not nan
% endingX = plot(time(endLocs(notNanEndLocs)),dataValues(endLocs(notNanEndLocs)),'rx');

%% Baseline
if ~isnan(threshold)
    thresholdL = plot(xlim,[threshold,threshold],'k-'); % plot the threshold
end

%% Legend
try
    if isnan(threshold)
%         legend([startingO,endingX],'starting point','end point');
        legend([startingO,endingX],'starting point');
    else
%         legend([startingO,endingX,thresholdL],'starting point','end point','threshold')
        legend([startingO,endingX,thresholdL],'starting point','threshold')
    end
catch
end    
clear notNanSpikeLocs baseline

hold off

end

