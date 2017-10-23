function p = plotFig(varargin)
%plotFig Plot data into figure.
% Variable "type" could be 'subplot' or 'overlap', default type is 'subplot'.
% Variable 'y' could be a matrix where the data in column will be plotted
% as one signal trial; Different rows represent different trials that have been performed.
%   p = plotFig(x, y, fileName, titleName, xScale, yScale, answerSave, answerShow, path, type)

%% fill unset parameters
if nargin == 1
    x = 1:size(varargin{1},1);
    y = varargin{1};
else
    x = varargin{1};
    y = varargin{2};
end

if nargin < 11;
    channel = 1;
else
    channel = varargin{11};
end
if nargin < 10
    type = 'subplot';
else
    type = varargin{10};
end
if nargin < 9
    path = '';
else
    path = varargin{9};
end
if nargin < 8
    answerShow = 'n';
else
    answerShow = varargin{8};
end
if nargin < 7
    answerSave = 'n';
else
    answerSave = varargin{7};
end
if nargin < 6
    yScale = '';
else
    yScale = varargin{6};
end
if nargin < 5
    xScale = '';
else
    xScale = varargin{5};
end
if nargin < 4
    titleName = '';
else
    titleName = varargin{4};
end
if nargin < 3
    fileName = '';
else
    fileName = varargin{3};
end

%% Plot
textSize = 8;

[numData, numPlot] = checkSize(y);
saveName = [titleName, ' ', fileName];

for i = 1:numData
    figure
    hold on;
    set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',textSize,...
        'PaperPositionMode', 'auto');
    for j = 1:numPlot
        if isequal(type, 'subplot')
            p(j,1) = subplot(numPlot,1,j);
            if numData > 1
                title([titleName, ' ', fileName, ' set ', num2str(j), ' ch ', num2str(channel(i))])
                saveName = [titleName, ' ', fileName, ' ch ', num2str(channel(i))];
            else
                title([titleName, ' ', fileName, ' ch ', num2str(channel(j))])
                saveName = [titleName, ' ', fileName, ' ch ', num2str(channel)];
            end
            hold on
        end
        plot(x,y(:,j,i));
        ylabel(yScale, 'FontSize', textSize);
        axis tight;
    end
    
    xlabel(xScale, 'FontSize', textSize);
    
    if isequal(type, 'subplot')
        linkaxes(p(:,1),'x');
    else
        title([titleName, ' ', fileName, ' ch ', num2str(channel(i))])
        saveName = [titleName, ' ', fileName, ' ch ', num2str(channel(i))];
    end
    
    hold off
    
    %% Save & Show
    if isequal(answerSave,'y')
        saveLocation = [path,'Figures\',titleName];
        if ~exist(saveLocation,'file')
            mkdir(saveLocation);
        end
        saveas(gcf,[saveLocation,'\',saveName,'.fig']);
        saveas(gcf,[saveLocation,'\',saveName,'.jpg']);
        disp('Figures saved...')
    end
    
    if ~isequal(answerShow,'y')
        close gcf
    end

end
end

