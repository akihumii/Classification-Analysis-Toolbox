function output = mergeChannelsInfo(data,input,numChannel,type)
%COMBINECHANNELS Merge the informations across all the channels
%   input:  type: 'just':  just merge without doing anything!
%                 'merge': use the first starting point and last end point
%                 'first': use the first starting point and first end point
%                 'merge overlap': only get those are closed enough to each other
%   output = mergeChannelsInfo(data,input)

locsAll = [input.spikeLocs(:), input.burstEndLocs(:)]; % [startLocs, endLocs]

locsAll = sortrows(locsAll,1); % sort according to startLocs

% to omit the bursts that are included in the previous burst
redundantEndLocs = diff(locsAll(:,2)) < 0; 
locsAllEdited = locsAll;
locsAllEdited([false;redundantEndLocs],:) = [];

% to omit the partially overlapping bursts
overlapBursts = [[locsAllEdited(:,1); inf], [0; locsAllEdited(:,2)]];

overlappingFlag = diff(overlapBursts,[],2) > 0;
switch type
    case 'just'
        
    case 'merge'
        overlapBursts(overlappingFlag,:) = [];
        locsAllEdited = [overlapBursts(1:end-1,1), overlapBursts(2:end,2)];
        locsAll = locsAllEdited;
    case 'first'
        locsAllEdited(overlappingFlag,:) = [];
        locsAll = locsAllEdited;
    case 'merge overlap'
        locsAllDiff = diff(locsAll(:,1));
        locsAllDiff = -locsAllDiff + 5;
        [~, locs] = triggerSpikeDetection(locsAllDiff, 0, 3, 3, 1);
        locsAll = locsAll(locs,:);
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

