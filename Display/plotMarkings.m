function [] = plotMarkings(handle,dataValues,samplingFreq,startingLocs,endLocs,baseline)
%plotMarkings Plot starting point, end point, baseline
%   [] = plotMarkings(axes,dataValues,startingLocs,endLocs,baseline)
axes(handle);

hold on

notNanSpikeLocs = ~isnan(startingLocs); % get start locs that are not nan
startingO = plot(startingLocs(notNanSpikeLocs)/samplingFreq,dataValues(startingLocs(notNanSpikeLocs)),'ro');
for k = 1:sum(notNanSpikeLocs)
    text(startingLocs(k)/samplingFreq,baseline,num2str(k))
end
notNanEndLocs = ~isnan(endLocs); % get end locs that are not nan
endingX = plot(endLocs(notNanEndLocs)/samplingFreq,dataValues(endLocs(notNanEndLocs)),'rx');
baselineL = plot(xlim,[baseline,baseline],'k-'); % plot the baseline

legend([startingO,endingX,baselineL],'starting point','end point','baseline')
clear notNanSpikeLocs baseline

hold off

end

