%% combinedFig
% this code can combine figures (mostly for lines) into one figure

% change the path to the one contains all the figures (.fig) that you want
% to combine.

% It will generate a .jpg and a .fig file
clear
close all

%% User input
titlename = ''; % input title of the figures here
xDomain = ''; % x label
yDomain = ''; % y label
legendName = ['']; % enter label name here and construct it in a tall matrix, eg. ['data1';'data2']

%% Main Dish
[files, path, iter] = selectFiles();
numFig = length(files);
color = hsv(numFig);
prompt = 'Title name: ';

% if something goes wrong, change 'a' into either 1 or 2
a = 1;
figname = [path,files{1}];
figopen = open(figname);
ax1 = get(figopen,'Children');
axChildren = allchild(ax1(a));
set(axChildren,'color',color(1,:));

for i = 2:numFig
    figname = [path,files{i}];
    figopen = open(figname);
    ax = get(figopen,'Children');
    axChildren = allchild(ax(a));
    set(axChildren,'color',color(i,:));
    copyobj(axChildren,ax1(a));
    close
end

%% Change title / xlabel / ylabel / legend / savename in this section
% title([titlename,' (Speed = 15cm/s)'],'FontSize',20,'FontWeight','Bold');
title(titlename,'FontSize',20,'FontWeight','Bold');
hold on
grid on
ylim auto
set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',16,...
    'PaperPositionMode', 'auto');
ylabel(yDomain);
xlabel(xDomain);

if isempty(legendName)
    legend
else
    legend(legendName)
end

saveas(gcf,[path,titlename,'.jpg']);
saveas(gcf,[path,titlename,'.fig']);

close;
