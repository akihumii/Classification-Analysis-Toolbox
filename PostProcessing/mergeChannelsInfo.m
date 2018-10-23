function output = mergeChannelsInfo(data,input)
%COMBINECHANNELS Merge the informations across all the channels
%   output = mergeChannelsInfo(data,input)

locsAll = [input.spikeLocs(:), input.burstEndLocs(:)]; % [startLocs x endLocs]

locsAll = sortrows(locsAll,1); % sort according to startLocs

% to omit the bursts that are included in the previous burst
redundantEndLocs = diff(locsAll(:,2)) < 0; 
locsAll([false;redundantEndLocs],:) = [];

% to omit the partially overlapping bursts
overlapBursts = [[locsAll(:,1); inf], [0; locsAll(:,2)]];
overlapBursts(diff(overlapBursts,[],2) > 0,:) = [];
locsAll = [overlapBursts(1:end-1,1), overlapBursts(2:end,2)];

locsAll = squeezeNan(locsAll,2);

%% Assign updated info
output = struct(...
    'spikePeaksValue',data(locsAll(:,1),:),...
    'spikeLocs',repmat(locsAll(:,1),1,2),...
    'parameters',input.parameters,...
    'burstEndValue',data(locsAll(:,2),:),...
    'burstEndLocs',repmat(locsAll(:,2),1,2));

output.baseline = input.baseline; % if put this in the struct function, the output will become 2x1 struct

end

