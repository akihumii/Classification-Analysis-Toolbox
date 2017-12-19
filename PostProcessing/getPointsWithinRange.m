function output = getPointsWithinRange(timeAxis,data,startLocs,endLocs,windowSize,samplingFreq, channelExtractStartingLocs)
%getPointsWithinRange Get the points within the range
%   function output = getPointsWithinRange(timeAxis,data,startLocs,endLocs,windowSize,samplingFreq, channelExtractStartingLocs)
%
% input: channelExtractStartingLocs: input the channel index (start from 1,
% then 2, 3,......) to fix the window size as the distance of the starting
% locations of two consecutive bursts. Input 0 to deactivate this function
%
% output: burst, xAxisValues,numBursts

[numRow,numColumn] = size(data);

for i = 1:numColumn
    if ~isnan(startLocs(1,i)) % if there is peak found in the channel
        % if channelExtractStartingLocs is not zero, use that particular
        % channel to extract the data and put into the matrix
        if channelExtractStartingLocs ~= 0
            ch = channelExtractStartingLocs;
            
            numLocs(i,1) = sum(~isnan(startLocs(:,ch))); % number of locations that is not NaN
            
            for j = 1:numLocs(i,1)-1
                burst{j,1} = data(transpose((floor(-windowSize(1,1)*samplingFreq)+startLocs(j,ch)):startLocs(j+1,ch)),i);
                xAxisValuesTemp = transpose(1+floor(-windowSize(1,1)*samplingFreq):startLocs(j+1,ch)-startLocs(j,ch)+1); % create an array of x axis values for burst plotting
                % get the correct time axis, because the xAxisValuesTemp might
                % start from negative value, so need to compensate that part
                minusLocation = 1-xAxisValuesTemp(1,1);
                timeTemp = timeAxis-timeAxis(minusLocation);
                xAxisValues{j,1} = timeTemp(1:length(xAxisValuesTemp));
            end
            
        else
            ch = i;
            
            numLocs(i,1) = sum(~isnan(startLocs(:,ch))); % number of locations that is not NaN
            
            for j = 1:numLocs(i,1)-1
                burst{j,1} = data(transpose((floor(-windowSize(1,1)*samplingFreq)+startLocs(j,ch)):endLocs(j,ch)+windowSize(1,2)*samplingFreq),i);
                xAxisValuesTemp = transpose(1+floor(-windowSize(1,1)*samplingFreq):endLocs(j,ch)-startLocs(j,ch)+1+windowSize(1,2)*samplingFreq); % create an array of x axis values for burst plotting
                % get the correct time axis, because the xAxisValuesTemp might start from negative value, so need to compensate that part
                minusLocation = 1-xAxisValuesTemp(1,1);
                timeTemp = timeAxis-timeAxis(minusLocation);
                xAxisValues{j,1} = timeTemp(1:length(xAxisValuesTemp));
            end
            
        end
        % for the last burst, in case the window size exceeds maximum number of sample points
        j = j+1;
        if endLocs(j,ch)+windowSize(1,2)*samplingFreq <= numRow
            endPointTemp = endLocs(j,ch)+windowSize(1,2)*samplingFreq;
        else
            endPointTemp = numRow;
        end
        burst{j,1} = data(transpose((floor(-windowSize(1,1)*samplingFreq)+startLocs(j,ch)):endPointTemp),i);
        xAxisValuesTemp = transpose(1+floor(-windowSize(1,1)*samplingFreq):endPointTemp-startLocs(j,ch)+1); % create an array of x axis values for burst plotting
        % get the correct time axis, because the xAxisValuesTemp might start from negative value, so need to compensate that part
        minusLocation = 1-xAxisValuesTemp(1,1);
        timeTemp = timeAxis-timeAxis(minusLocation);
        xAxisValues{j,1} = timeTemp(1:length(xAxisValuesTemp));
        
    else
        numLocs(i,1) = 0;
        burst{1,1} = nan;
        xAxisValues{1,1} = nan;
    end
    burstAll{i,1} = cell2nanMat(burst);
    xAxisValuesAll{i,1} = cell2nanMat(xAxisValues);
end

burstAll = cell2nanMat(burstAll);
xAxisValuesAll = cell2nanMat(xAxisValuesAll);

output.burst = burstAll;
output.burstMean = nanmean(burstAll,2); % get the mean of the windows
output.xAxisValues = xAxisValuesAll;
output.numBursts = numLocs;
end

