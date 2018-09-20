function varargout = plotFig(varargin)
%plotFig Plot data into figure.
% Any number of input is possible, as long as they are in order:
% (If there is only one input, it will be y value.)
%
% input:    "type" could be 'subplot', 'overlap' or 'overlapAll', default type is 'subplot'
%           'x' would be the xbinsWidth if 'plotWay' is 'histPlot', input 0 if it is not specified into any value
%           'y' could be a matrix where the data in column will be plotted as one signal trial; Different rows represent different trials that have been performed.
%           'plotWay' could be 'linePlot', 'barPlot', 'barGroupedPlot', 'stemPlot','histPlot', 'histFitPlot', 'scatterPlot', default way is 'linePlot'
%           'channel' is for the title purpose, default value is 1.
%
% output:   p: the axes
%           f: the figure
%
% saveName = subplot: [titleName, ' ', fileName]
%            overlap: [titleName, ' ', fileName, ' ch ', num2str(channel(i))]
%
%   [p,f] = plotFig(x, y, fileName, titleName, xScale, yScale, answerSave,
%                   answerShow, path, type, channel, plotWay)

%% Parameters
titleFontSize = 14; % title font size (normalized)
textSize = 10; % axis font size (normalized)
lineThickenss = 2; % border line width
chunkText = 'channel';
sizeUnit = 'points'; % 'points' as default or 'normalized'
textThickness = 'bold'; % 'normal' as default or 'bold', for the axes fonts

%% fill unset parameters
if nargin == 1
    x = transpose(1:size(varargin{1},1));
    y = varargin{1};
else
    x = varargin{1};
    y = varargin{2};
end

if nargin < 12;
    plotWay = 'linePlot';
else
    plotWay = varargin{12};
end

if nargin < 11;
    channel{1,1} = 0;
    %     channel = 1:size(y,2); % create a matrix
    %     channel = mat2cell(channel',ones(1,size(channel,2)),size(channel,1)); % convert the matrix into cell
else
    channel = varargin{11};
    if channel == 0
        channel = zeros(1,size(y,2)); % create a zeros matrix
        channel = mat2cell(channel',ones(1,size(channel,2)),size(channel,1)); % convert the matrix into cell
    else
        channel = checkSizeNTranspose(channel,2);
        channel = mat2cell(channel,ones(1,size(channel,1)),size(channel,2)); % convert the matrix into cell
    end
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
    answerShow = 1;
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
[numData, numPlot] = checkSize(y);
if isequal(plotWay,'barStackedPlot')
    numPlot = 1;
end
saveName = [titleName, ' ', fileName];

[numDataX, ~] = checkSize(x);
if ~isequal(plotWay,'histPlot')
    if numDataX == 1 && numData ~= 1
        x = repmat(x,1,1,numData);
    end
end

for i = 1:numData
    f(i,1) = figure;
    hold on;
    set(gcf, 'Position', get(0,'Screensize')-[0 0 0 80],'PaperPositionMode', 'auto');
    
    if channel{1,1} ~= 0
        titleTemp = [' ch ', checkMatNAddStr(channel{i},' - ')];
    else
        titleTemp = '';
    end
    
    for j = 1:numPlot
        % Titling
        if channel{1,1} ~= 0 & length(channel) >= numPlot
            titleTemp = [' ',chunkText,' ', checkMatNAddStr(channel{j},' - ')];
        end
        
        if isequal(type, 'subplot')
            p(j,i) = subplot(numPlot,1,j);
            
            if numData > 1
                title([titleName, ' ', fileName, ' set ', num2str(j), titleTemp], 'Fontunit', sizeUnit, 'FontSize', titleFontSize)
                saveName = [titleName, ' ', fileName, titleTemp];
            else
                title([titleName, ' ', fileName, titleTemp], 'Fontunit', sizeUnit, 'FontSize', titleFontSize)
                saveName = [titleName, ' ', fileName, titleTemp];
            end
            hold on
            ylabel(yScale, 'Fontunit', sizeUnit, 'FontSize', textSize, 'FontWeight', textThickness);
            set(gca, 'Fontunit', sizeUnit, 'FontSize', textSize, 'LineWidth', lineThickenss, 'FontWeight', textThickness);
            
        else
            p(i,1) = gca;
            
        end
        
        % Plotting
        switch plotWay
            case 'linePlot'
                if any(size(x)==1)
                    l(j,i) = plot(x,y(:,j,i));
                else
                    l(j,i) = plot(x(:,j,i),y(:,j,i));
                end
            case 'barPlot'
                if any(size(x)==1)
                    l(j,i) = bar(x,y(:,j,i));
                else
                    l(j,i) = bar(x(:,j,i),y(:,j,i));
                end
            case 'barGroupedPlot'
                if all(size(x)==1)
                    y = checkSizeNTranspose(y,1);
                    l(i,:) = bar([x,x+1],[y(:,:,i);nan(size(y(:,:,i)))]);
                    xlim([0.5,1.5]);
                elseif any(size(x)==1)
                    if size(y,2) == 1
                        y = checkSizeNTranspose(y,1);
                        l(i,:) = bar([x,x+1],[y(:,:,i);nan(size(y(:,:,i)))]);
                        xlim([0.5,1.5]);
                    else
                        l(i,:) = bar(x,y(:,:,i));
                    end
                else
                    l(i,:) = bar(x(:,j,i),y(:,:,i));
                end
            case 'stemPlot'
                if any(size(x)==1)
                    l(j,i) = stem(x,y(:,j,i));
                else
                    l(j,i) = stem(x(:,j,i),y(:,j,i));
                end
            case 'histPlot'
                if x ~= 0 || length(x) == 1
                    xbinsTemp = min(y) : x : max(y);
                    l(j,i) = histogram(y,xbinsTemp);
                else
                    l(j,i) = histogram(y);
                end
            case 'histFitPlot'
                pTemp = histfit(y(:,j,i));
                pTemp(1,1).FaceAlpha = 0.2;
                l{j,i} = pTemp;
            case 'scatterPlot'
                l(j,i) = scatter(x(:,j,i),y(:,j,i),500,'.');
%             case 'boxPlot'
%                 % refer to https://www.mathworks.com/matlabcentral/answers/171414-how-to-show-95-quanile-in-a-boxplot
%                 q95 = quantile(y(:,j,i),0.95);
%                 q75 = quantile(y(:,j,i),0.75);
%                 q25 = quantile(y(:,j,i),0.25);
%                 w95 = (q95-q75) / (q75-q25);
%                 l(j,i) = box(y(:,j,i),'whisker',w95);
            otherwise
                error('Invalid plotway...')
        end
        
%         axis tight;
    end
    ylabel(yScale, 'Fontunit', sizeUnit, 'FontSize', textSize, 'FontWeight', textThickness);
    
    xlabel(xScale, 'Fontunit', sizeUnit, 'FontSize', textSize, 'FontWeight', textThickness);
    
    if isequal(type, 'subplot')
        linkaxes(p(:,1),'x');
    else
        title([titleName, ' ', fileName, titleTemp], 'Fontunit', sizeUnit, 'FontSize', titleFontSize)
        saveName = [titleName, ' ', fileName, titleTemp];
    end
    
    set(gca, 'Fontunit', sizeUnit, 'FontSize', textSize, 'FontWeight', textThickness);
    
    hold off
    
    %% Save & Show
    if answerSave
        savePlot(path,titleName,fileName,saveName)
    end
    
    if ~answerShow
        close gcf
    end
    
end

%% Output
varargout{1} = p;
if nargout > 1
    varargout{2} = f;
end
if nargout > 2
    varargout{3} = l;
end