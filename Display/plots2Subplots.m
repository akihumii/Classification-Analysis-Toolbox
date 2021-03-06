function varargout = plots2subplots(plots,rowSubplot,colSubplot,titleName)
%plots2subplots Plot the plots into subplot
% 
% input:    titleName is optional
% 
% output:   varargin{1,1} = axes;
%           varargin{2,1} = figure;
% 
%   p = plots2subplots(plots,rowSubplot,colSubplot,titleName)

if nargin < 4
    titleName = repmat({''},rowSubplot*colSubplot,1);
end
    
textSize = 16;

f = figure;
hold on;

originalPlots = reshape(plots,rowSubplot,colSubplot);
titleName = reshape(titleName,rowSubplot,colSubplot);

for i = 1:rowSubplot
    for j = 1:colSubplot
        sp(i,j) = subplot(rowSubplot,colSubplot,(i-1)*colSubplot+j);        
%         set(gca,'fontSize',textSize);
        newSp(i,j) = copyAxes(f,originalPlots(i,j), sp(i,j), titleName{i,j});
    end
end

% linkaxes(sp(:,:),'x');

set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',textSize,...
    'PaperPositionMode', 'auto');

delete(plots)
%% output
varargout{1,1} = newSp;
if nargout == 2
    varargout{2,1} = f;
end

end

