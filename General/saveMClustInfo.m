function [] = saveMClustInfo(signalClassification, signal, dataType)
%SAVEMCLUSTINFO Save the required information for MClust
%   [] = saveMClustInfo(signalClassification, signal)

[numSpikes, numChannel] = size(signalClassification.burstDetection.spikeLocs);

% block_t [number of spikes x 1] double
block_t = transpose(1:numSpikes);

% wv [number of spikes x channel x data points]
signalClassification.burstDetection.spikeLocs =...
    signalClassification.burstDetection.spikeLocs - 2;
signalClassification.burstDetection.burstEndLocs =...
    signalClassification.burstDetection.burstEndLocs - 2;

for i = 1 : numChannel
    for j = 1 : numSpikes
        switch dataType
            case 'dataFiltered'
                wv(j,i,:) = -signal.dataFiltered.values(...
                    signalClassification.burstDetection.spikeLocs(j,i):...
                    signalClassification.burstDetection.burstEndLocs(j,i),...
                    i);
            case 'dataRaw'
            otherwise
                error('Invalid dataType in saveMClustInfo...')
        end        
    end
end

wv = repmat(wv(:,1:2,:),1,2,1);  % omit the 3rd channel and repeat the first 2 channels again to make it 4 in total

% save
saveFilename = [signal.path,'Info',filesep,signal.fileName,'MClustInfo_',time2string,'.mat'];
save(saveFilename,'block_t','wv','signalClassification');
fprintf('%s has been saved...\n', saveFilename);
end

