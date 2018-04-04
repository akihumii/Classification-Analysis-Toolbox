function output = pulse2spike(data,samplingFreq,minDistance,threshold,type)
%pulse2spike Convert the pulse into spike 
% 
% input:    samplingFreq(optional): default is 1
%           minDistance(optional): default is 1
%           threshold(optional): default is baselineInfo.mean + baselineStdMult * baselineInfo.std
%           type: 'local maxima' or 'trigger'. 'trigger' will get the first point exceeding the threshold while 'local maxima' will get the maximum.
% 
%   output = pulse2spike(data,samplingFreq,minDistance,threshold,type)

if nargin < 2
    threshold = 0;
    samplingFreq = 1;
    minDistance = 1;
end

baselineStdMult = 5;

[rowData,colData] = size(data);

for i = 1:colData
    dataTemp = data(:,i);
    baselineInfo = baselineDetection(dataTemp);
    if threshold == 0
        thresholdTemp(i,1) = baselineInfo.mean + baselineStdMult * baselineInfo.std;
    else
        thresholdTemp(i,1) = threshold(1,i);
    end

    switch type
        case 'trigger'
            [spikePeaks{i,1},spikeLocs{i,1}] = triggerSpikeDetection(dataTemp,thresholdTemp(i,1),minDistance*samplingFreq);
        case 'local maxima'
            [spikePeaks{i,1},spikeLocs{i,1}] = findpeaks(dataTemp,'MinPeakHeight',thresholdTemp(i,1),'MinPeakDistance',minDistance*samplingFreq);
        otherwise
            error('No peak detection type is input...')
    end
    
    % Plotting
    s(i,1) = plotFig((1:rowData)/samplingFreq,dataTemp,'','Spike plots of first peak','Time(s)','Amplitude(V)',0,1,'','subplot',1); % plot the analysing data
    hold on
    f = stem(spikeLocs{i,1}/samplingFreq,spikePeaks{i,1},'x','lineWidth',2); % plot the first peak locations
    l = plot(xlim,[thresholdTemp(i,1),thresholdTemp(i,1)],'g-'); % plot the threshold line
    
%     dataDiff = diff(data(:,i)); % difference of the data;
%     spikeLocs = (dataDiff > threshold) == 1; % locations of the points that exceed threshold
%     spikeLocsDiff = diff(spikeLocs); % distance between each raw spike locations
    
end

spikePeaks = cell2nanMat(spikePeaks);
spikeLocs = cell2nanMat(spikeLocs);

output.spikePeaks = spikePeaks;
output.spikeLocs = spikeLocs;
output.threshold = thresholdTemp;
output.figures = s;
end

