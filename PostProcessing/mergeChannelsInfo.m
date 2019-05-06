function output = mergeChannelsInfo(data,input,numChannel,type)
%COMBINECHANNELS Merge the informations across all the channels
%   input:  type: 'merge': use the first starting point and last end point
%                 'first': use the first starting point and first end point
%   output = mergeChannelsInfo(data,input)

locsAll = [input.spikeLocs(:), input.burstEndLocs(:)]; % [startLocs, endLocs]

locsAll = sortrows(locsAll,1); % sort according to startLocs

% to omit the bursts that are included in the previous burst
redundantEndLocs = diff(locsAll(:,2)) < 0; 
locsAll([false;redundantEndLocs],:) = [];

% to omit the partially overlapping bursts
overlapBursts = [[locsAll(:,1); inf], [0; locsAll(:,2)]];

overlappingFlag = diff(overlapBursts,[],2) > 0;
switch type
    case 'merge'
        overlapBursts(overlappingFlag,:) = [];
        locsAll = [overlapBursts(1:end-1,1), overlapBursts(2:end,2)];
    case 'first'
        locsAll(overlappingFlag,:) = [];
    otherwise
        error('Invalid mergeChannelsInfo')
end

locsAll = squeezeNan(locsAll,2);

locsAll = omitNan(locsAll, 2, 'any');

%% Assign updated info
output = struct(...
    'spikePeaksValue',data(locsAll(:,1),:),...
    'spikeLocs',repmat(locsAll(:,1),1,numChannel),...
    'threshold',input.threshold,...
    'burstEndValue',data(locsAll(:,2),:),...
    'burstEndLocs',repmat(locsAll(:,2),1,numChannel),...
    'parameters',input.parameters);

output.baseline = input.baseline; % if put this in the struct function, the output will become 2x1 struct

end

