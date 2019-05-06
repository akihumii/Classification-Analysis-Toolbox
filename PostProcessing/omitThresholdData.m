function output = omitThresholdData(signal, locations, parameters)
%OMITTHRESHOLDDATA Omit the chunks found in peak detection with the window
%size 
% 
%   signal = omitThresholdData(signal, locations, parameters)

numBursts = size(locations,1);

for i = 1:length(signal)
    windowOmitPoints = parameters.windowSizeThresholdOmit * signal(i,1).samplingFreq;
    startingPoint{i,1} = locations + windowOmitPoints(1,1);
    endPoint = locations + windowOmitPoints(1,2);
    
    % find out the deleting indices
    for j = 1:size(locations, 2)
        for k = 1:numBursts
            deletingIndexCell{k,j} = floor(startingPoint{i,1}(k,j) : endPoint(k,j));
        end
    end
        
    % delete the corresponding points
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataRaw', deletingIndexCell, 'interpolate');
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'time', deletingIndexCell, 'interpolate');
    
    signal(i,1) = rectifyData(signal(i,1),'dataRaw'); % rectify data
    signal(i,1) = filterData(signal(i,1),parameters); % filter data
    signal(i,1) = TKEO(signal(i,1),'dataRaw'); % TKEO
    if ~isempty(signal(i,1).dataFFT)
        signal(i,1) = fftDataConvert(signal(i,1),parameters.dataToBeFFT); % do FFT
    end
    
    % cut again after the filter artifact has been prevented
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataRaw', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataAll', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'time', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataRectified', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataFiltered', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataTKEO', deletingIndexCell, parameters.stitchFlag);
    signal(i,1) = deleteCorrespondingIndex(signal(i,1), 'dataFFT', deletingIndexCell, parameters.stitchFlag);
    
    % update starting point
    if ~strcmp(parameters.stitchFlag, 'interpolate')
        startingPoint{i,1} = updateStartingPoint(startingPoint{i,1}, length(deletingIndexCell{1,1}));
    end
end

startingPoint = cell2nanMat(startingPoint);

% figure
% plot(signal(i,1).dataRaw(:,1));
% figure
% plot(signal(i,1).dataFiltered.values(:,1));

%% Output
output = makeStruct(...
    signal,...
    startingPoint);

end

function dataNew = updateStartingPoint(data, windowSize)
numBursts = size(data,1);
windowExtra = transpose(0 : windowSize : windowSize * (numBursts-1));
dataNew = data - windowExtra;
end

function signal = deleteCorrespondingIndex(signal, dataName, deletingIndex, stitchFlag)
data = signal.(dataName);
% get the data values
if isstruct(signal.(dataName))
    data = data.values;
end

% delete data
for i = 1:size(data,2)
    dataTemp{i,1} = data(:,i);
    if strcmp(stitchFlag, 'interpolate')
        if ~strcmp(dataName, 'time')
            numBursts = length(deletingIndex);
            for j = 1:numBursts
                if ~isnan(deletingIndex{j,i})
                    lenBursts = length(deletingIndex{j,i});
                    startingValue = dataTemp{i,1}(deletingIndex{j,i}(1,1) - 1);
                    endValue = dataTemp{i,1}(deletingIndex{j,i}(1,end) + 1);
                    dataInterpolationTemp = linspace(startingValue, endValue, lenBursts);
                    dataTemp{i,1}(deletingIndex{j,i}) = dataInterpolationTemp;
                end
            end
        end        
    else
        if i <= size(deletingIndex,2)
            deletingIndexTemp = reshape(cell2nanMat(deletingIndex(:,i)), [], 1);
        else
            deletingIndexTemp = reshape(cell2nanMat(deletingIndex(:,1)), [], 1);
        end
        dataTemp{i,1}(deletingIndexTemp(~isnan(deletingIndexTemp))) = [];
    end
    
    if strcmp(stitchFlag, 'stitch') && strcmp(dataName, 'time')
        dataTemp{i,1} = transpose(1:size(dataTemp{i,1}, 1));
    end
end


% replace the values in signal object
if isstruct(signal.(dataName))
    signal.(dataName).values = cell2nanMat(dataTemp);
elseif ~isempty(data)
    signal.(dataName) = cell2nanMat(dataTemp);
end
end
