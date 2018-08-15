function [] = visualizeDetectedPoints(signal,startingPoints,endPoints,samplingFreq,fileName,path)
%visualizeDetectedPoints Visualize the detected points in the signal
%   [] = visualizeDetectedPoints(signal,startingPoints,endPoints,samplingFreq,fileName,path)

p = plotFig((1:length(signal))/samplingFreq,signal,fileName,'Detected Bursts by Classifier','Time(s)','Amplitude(V)',...
    0,1,... % save & show
    path,'subplot');

hold on

numChannel = length(p);

for i = 1:numChannel
    axes(p(i));
    startingPointsTemp = startingPoints(~isnan(startingPoints(:,i)),i);
    endPointsTemp = endPoints(~isnan(endPoints(:,i)),i);
    sp = plot(startingPointsTemp/samplingFreq,signal(startingPointsTemp,i),'ro'); % staring points
    ep = plot(endPointsTemp/samplingFreq,signal(endPointsTemp,i),'rx'); % end pointss
    legend([sp,ep],'starting points','end points')
end

end

