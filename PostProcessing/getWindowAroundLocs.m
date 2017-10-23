function [xAxisValues, yAxisValues] = getWindowAroundLocs(signalValues, samplingFreq, signalClassification, extraTimeAddedBeforeStartLocs, extraTimeAddedAfterEndLocs)
%getWindowAroundLocs Output windows around given locations
%   [xAxisValues, yAxisValues] = getWindowAroundLocs(signal, signalClassification, extraTimeAddedBeforeStartLocs, extraTimeAddedAfterEndLocs)

xAxisValuesStartLocs = signalClassification.burstDetection.spikeLocsUpdated -...
    (signalClassification.window(1) + extraTimeAddedBeforeStartLocs)*samplingFreq;
xAxisValuesEndLocs = signalClassification.burstDetection.spikeLocsUpdated +...
    (signalClassification.window(2) + extraTimeAddedAfterEndLocs)*samplingFreq;

xAxisValues = ((0 - (signalClassification.window(1) + extraTimeAddedBeforeStartLocs))*samplingFreq:...
    (signalClassification.window(2) + extraTimeAddedAfterEndLocs)*samplingFreq) / samplingFreq;

[numWindow, numChannel] = size(xAxisValuesEndLocs);

for c = 1:numChannel
    for w = 1:numWindow
        if ~isnan(xAxisValuesStartLocs(w,c)) && ~isnan(xAxisValuesEndLocs(w,c))
            yAxisValues(:,w,c) = signalValues(floor(xAxisValuesStartLocs(w,c):...
                xAxisValuesEndLocs(w,c)),...
                c);
        end
    end
end
end

