function output = getBaselineFeature(burstDetection,samplingFreq,data,type,dataForThreshChecking)
%GETBASELINEFEATURE Get the baseline feature by using the baseline defined
%earlier
% input: type = 'invert'; % 'invert' or 'sorted'
% 
%   output = getBaselineFeature(burstDetection,samplingFreq,data,type)


numChannel = length(burstDetection.baseline);

numBurst = size(burstDetection.spikePeaksValue,1);

for i = 1:numChannel
    switch type
        case 'sorted'

            baselineBursts{i,1} = burstDetection.baseline{i,1}.array;
            numSample = length(baselineBursts{i,1});
            
            % trim the baseline to make it divisible by numBurst
            numNice = floor(numSample/numBurst) * numBurst;
            baselineBursts{i,1} = baselineBursts{i,1}(1:numNice);
            
            baselineBursts{i,1} = reshape(baselineBursts{i,1},[],numBurst);
            
        case 'invert'
            
            baselineBursts{i,1} = cell(numBurst,1); % make it the same length as the bursts
            
            if ~all(isnan(burstDetection.burstEndLocs(:,i)))
                if ~isempty(burstDetection.burstEndLocs(:,i))
                    burstEndLocsTemp = squeezeNan(burstDetection.burstEndLocs(:,i),2);
                    spikeLocsTemp = squeezeNan(burstDetection.spikeLocs(:,i),2);
                    
                    numBursts = length(burstEndLocsTemp);
                    if  numBursts >= 2
                        baselineStartLocs{i,1} = [1;burstEndLocsTemp(1:end-1)];
                        baselineEndLocs{i,1} = spikeLocsTemp(1:end);
                        
                        numBaselineBurst = length(baselineStartLocs{i,1});
                        for j = 1:numBaselineBurst
                            baselineBurstsTemp = dataForThreshChecking(baselineStartLocs{i,1}(j,1):baselineEndLocs{i,1}(j,1),i);
                            [peakTemp,~] = triggerSpikeDetection(baselineBurstsTemp,burstDetection.threshold(i,1),0,burstDetection.parameters.TKEOStartConsecutivePoints(1,i),0);
                            if isnan(peakTemp)
                                baselineBursts{i,1}{j,1} = data(baselineStartLocs{i,1}(j,1):baselineEndLocs{i,1}(j,1),i);
                            else
                                baselineBursts{i,1}{j,1} = nan;
                            end
                        end
                        baselineBursts{i,1} = cell2nanMat(baselineBursts{i,1});
                    elseif numBursts == 1
                        baselineStartLocs{i,1} = 1;
                        baselineEndLocs{i,1} = spikeLocsTemp(1,1);
                        
                        baselineBursts{i,1}{1,1} = data(baselineStartLocs{i,1}:baselineEndLocs{i,1},i);
                        baselineBursts{i,1} = cell2nanMat(baselineBursts{i,1});
                    else % when no burst is found
%                         baselineBursts{i,1} = data(:,i);
                    end
                end
            else
                lengthData = size(data,1);
                baselineStartLocs{i,1} = 1;
                baselineEndLocs{i,1} = lengthData;
                
                baselineBursts{i,1}{1,1} = data(baselineStartLocs{i,1}:baselineEndLocs{i,1},i);
                baselineBursts{i,1} = cell2nanMat(baselineBursts{i,1});
            end
            
        case 'movingWindow'
            maxWindowSize = max(burstDetection.burstEndLocs-burstDetection.spikeLocs,[],1);
            baselineBursts{i,1} = getMovingWindowBaseline(data(data(:,i)~=0,i),dataForThreshChecking(:,i),...
                burstDetection.threshold(i,1),numBurst,maxWindowSize);
            
        otherwise
            error('Invalid method ot get the baseline feature...');
    end
    
    baselineInfo{i,1} = getBasicParameter(reshape(baselineBursts{i,1},[],1));
end

baselineBursts = cell2nanMat(baselineBursts);

if size(baselineBursts,3) ~= numChannel
    baselineBursts = permute(baselineBursts,[1,3,2]);
end

baselineFeature = featureExtraction(baselineBursts,samplingFreq);

%% output
output = makeStruct(...
    baselineBursts,...
    baselineFeature,...
    baselineInfo);


end

