function output = omitThresholdData(signal, locations, parameters)
%OMITTHRESHOLDDATA Omit the chunks found in peak detection with the window
%size 
% 
%   signal = omitThresholdData(signal, locations, parameters)

numBursts = size(locations,1);

for i = 1:length(signal)
    windowOmitPoints = parameters.windowSizeThresholdOmit * signal(i,1).samplingFreq;
    startingPoint = locations + windowOmitPoints(1,1);
    endPoint = locations + windowOmitPoints(1,2);
    
    % find out the deleting indices
    for k = 1:numBursts
        deletingIndexCell{k,1} = startingPoint(k,1) : endPoint(k,1);
    end
    deletingIndex(:,1) = reshape(cell2nanMat(deletingIndexCell(:,1)), [], 1);
        
    % delete the corresponding points
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataRaw', deletingIndex);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'time', deletingIndex);
    
    signal(i,1) = rectifyData(signal(i,1),'dataRaw'); % rectify data
    signal(i,1) = filterData(signal(i,1),parameters); % filter data
    signal(i,1) = TKEO(signal(i,1),'dataRaw'); % TKEO
    if ~isempty(signal(i,1).dataFFT)
        signal(i,1) = fftDataConvert(signal(i,1),parameters.dataToBeFFT); % do FFT
    end
    
    % update starting point
    startingPointNew = updateStartingPoint(startingPoint, length(deletingIndexCell{1,1}));
    
end

% figure
% plot(signal(i,1).dataRaw(:,1));
% figure
% plot(signal(i,1).dataFiltered.values(:,1));

%% Output
output = makeStruct(...
    signal,...
    startingPointNew);

end

function dataNew = updateStartingPoint(data, windowSize)
numBursts = size(data,1);
windowExtra = transpose(0 : windowSize : windowSize * (numBursts-1));
dataNew = data - windowExtra;
end

function signal = deleteCorrespondingIndex(signal, dataName, deletingIndex)
data = signal.(dataName);
if isstruct(signal.(dataName))
    data = data.values;
end
if strcmp(dataName, 'time')
    data = data';
end

for i = 1:size(data,2)
    dataTemp{i,1} = data(:,i);
    dataTemp{i,1}(deletingIndex(:,1)) = [];
end

if isstruct(signal.(dataName))
    signal.(dataName).values = cell2nanMat(dataTemp);
elseif strcmp(dataName, 'time')
    signal.(dataName) = cell2nanMat(dataTemp)';
else
    signal.(dataName) = cell2nanMat(dataTemp);
end
end