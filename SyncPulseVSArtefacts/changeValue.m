%CHANGEVALUE Change the value
%   Change the value in one of the plot
data = signal;

[files,path,iter] = selectFiles();

figCheck = open([path,files{1,1}]);
delete(figCheck); clear figCheck


%% open separated files and get the values
for i = 1:iter
    fig = open([path,files{1,1}]); % open figures
    dataX = fig.Children(end).Children(end).XData; %
    colorTemp = fig.Children(end).Children(end).Color; % color
    delete(fig.Children(end).Children(end)); % delete the original line
    axes(fig.Children(end)) % change to first subplot
    plot(dataX,data(i,1).dataRaw(:,1),'Color',colorTemp);
    ylim auto;
    yRange = fig.Children(1).YLim;
    numChildren = length(fig.Children(1).Children);
    for j = 3:numChildren
        fig.Children(1).Children(j).YData = yRange;
    end
    axis tight
    savefig([path,files{i,1}])
    
end

% close

