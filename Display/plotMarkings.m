function [] = plotMarkings(handle,dataValues,samplingFreq,startingLocs,endLocs,baseline)
%plotMarkings Plot starting point, end point, baseline
%   [] = plotMarkings(axes,dataValues,startingLocs,endLocs,baseline)
axes(handle);

hold on

%% Starting Point
notNanSpikeLocs = ~isnan(startingLocs); % get start locs that are not nan
startingO = plot(startingLocs(notNanSpikeLocs)/samplingFreq,dataValues(startingLocs(notNanSpikeLocs)),'ro');

%% Text Underneath
% for k = 1:sum(notNanSpikeLocs)
%     text(startingLocs(k)/samplingFreq,baseline,num2str(k))
% end

%% End Point
notNanEndLocs = ~isnan(endLocs); % get end locs that are not nan
endingX = plot(endLocs(notNanEndLocs)/samplingFreq,dataValues(endLocs(notNanEndLocs)),'rx');

%% Baseline
baselineL = plot(xlim,[baseline,baseline],'k-'); % plot the baseline

%% Legend
legend([startingO,endingX,baselineL],'starting point','end point','baseline')
% legend([startingO,endingX],'starting point','end point')
clear notNanSpikeLocs baseline

hold off

end

