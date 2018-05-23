function output = detectChanges(data,stepSize,blockWindow)
%DETECTCHANGES Generate the locations where changes happen.
% input:    column = different variables, row = observations.
%           stepSize = minimum changes in amplitude 
%           blockWindow = minimum distance between two spikes
% 
%   output = detectChanges(data,stepSize,blockWindow)

[numRow,numCol] = size(data);

for i = 1:numCol
    % initialize
    spikeLocs{i,1} = -stepSize;
    spikePeaks{i,1} = 0;

    locsLengthTemp = 0;
    
    for j = 1:numRow-1
        % only do the detection when the current point is away from the last found change with a distance of blockWindow
        if j-spikeLocs{i,1}(end) > blockWindow && locsLengthTemp ~= length(spikeLocs{i,1}) 
            if diff(data(j:j+1),i) > stepSize
                spikeLocs{i,1} = [spikeLocs{i,1}; j+1];
                spikePeaks{i,1} = [spikePeaks{i,1}; data(j+1)];
            end
        end
        locsLengthTemp = locsLengthTemp + 1;
    end
    spikeLocs{i,1} = spikeLocs{i,1}(2:end);
    spikePeaks{i,1} = spikePeaks{i,1}(2:end);
end

output.spikeLocs = cell2nanMat(spikeLocs);
output.spikePeaks = cell2nanMat(spikePeaks);
end

