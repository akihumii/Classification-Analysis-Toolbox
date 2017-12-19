function [newLocs,varargout] = trimCorrespondingSpikes(locs, tolerance,varargin)
%trimCorrespondingSpikes Trim out the extra spikes that are not related
%enough to the other set of spikes by checking the tolerance
% 
% input:    varargin(optionsl): can input the variables that need to be 
% trimmed according to the locs.
% 
%   [newLocs] = trimCorrespondingSpikes(locs, tolerance, varargin)

[rowLocs,colLocs] = size(locs);

numRounding = decimal2roundingN(tolerance);

locsRounded = round(locs,numRounding);

trimA = ismember(locsRounded(:,1),locsRounded(:,2));
trimB = ismember(locsRounded(:,2),locsRounded(:,1));

newLocs(:,1) = locs(trimA,1);
newLocs(:,2) = locs(trimB,2);

for i = 1 : nargin-2
    varargout{i,1}(:,1) = varargin{i,1}(trimA,1);
    varargout{i,1}(:,2) = varargin{i,1}(trimB,2);
end

end


