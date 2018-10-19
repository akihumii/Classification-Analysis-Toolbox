function output = getBaselineFeature(data,input)
%GETBASELINEFEATURE Get the features for baseline, the bursts in this case
%is the chunks that are not detected as bursts, which is the part starting
%from the burst offset to the next burst's onset.
%
%   [] = getBaselineFeature(data,input)

numChannel = size(input.spikePeaksValue,2);

for i = 1:numChannel
    baselineStartLocs{i,1} = zeros(0,1);
    baselineEndLocs{1,1} = zeros(0,1);
    
    if ~all(isnan(input.burstEndLocs(:,i)))
        if ~isempty(input.burstEndLocs(:,i))
            baselineStartLocs{i,1} = 0;
            baseline
            if length(input.burstEndLocs(:,i)) >= 2
                baselineStartLocs{i,1} = input.burstEndLocs(1:end-1);
                baselineEndLocs{i,1} = input.spikeLocs(2:end);
                baselinePeaksValue{i,1} = data(baselineStartLocs{i,1}:baselineEndLocs{i,1},i);
            end
        end
    end
    
    
end

