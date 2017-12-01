function p = plotFig(varargin)
%plotFig Plot data into figure.
% Any number of input is possible, as long as they are in order:
% (If there is only one input, it will be y value.)
% 
% Variable "type" could be 'subplot' or 'overlap', default type is 'subplot'.
% 
% Variable 'y' could be a matrix where the data in column will be plotted
% as one signal trial; Different rows represent different trials that have been performed.
% 
% Variable 'channel' is for the title purpose, default value is 1.
% 
%   p = plotFig(x, y, fileName, titleName, xScale, yScale, answerSave, answerShow, path, type, channel, continuePlotting)

%% fill unset parameters
if nargin == 1
    x = transpose(1:size(varargin{1},1));
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
    answerShow = 0;
else
    answerShow = varargin{8};
end
if nargin < 7
    answerSave = 0;
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
        % Titling
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
        
        % Plotting
        if any(size(x)==1)
            plot(x,y(:,j,i));
        else
            plot(x(:,j),y(:,j,i));
        end
        axis tight;
    end
    ylabel(yScale, 'FontSize', textSize);

    xlabel(xScale, 'FontSize', textSize);
    
    if isequal(type, 'subplot')
        linkaxes(p(:,1),'x');
    else
        title([titleName, ' ', fileName, ' ch ', num2str(channel(i))])
        saveName = [titleName, ' ', fileName, ' ch ', num2str(channel(i))];
    end
    
    hold off
    
    %% Save & Show
    if answerSave
        savePlot(path,titleName,fileName)
    end
    
    if ~answerShow
        close gcf
    end

end
end

