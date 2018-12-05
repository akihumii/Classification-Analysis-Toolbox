function [] = editBarPlot()
%EDITBARPLOT Combine the bars in different figures.
%   Detailed explanation goes here

close all

%% Parameters
parameters = struct(...
    'numBarShown',2,...
    'numBarActual',2,...
    'xLabelText','Day',...
    'yLabelText','Accuracy',...
    'saveBarPlot',1);
parameters.trimId = {0};
parameters.legendArray = {'10';'20'};
% parameters.legendArray = {'TA';'GC'};

% parameters.xTickLabel = {...
%             'maxValue';...
%             'minValue';...
%             'burstLength';...
%             'areaUnderCurve';...
%             'meanValue';...
%             'sumDifferences';...
%             'numZeroCrossings';...
%             'numSignChanges'};

% parameters.trimId = {[5,10];2}; % will be separated into two structures if they are assigned with 'struct'

%% Select files
[files,path,iters] = selectFiles('Select all the matlab figures to plot the combined plot');

%% Process
for i = 1:iters
    
    p(i,1) = open([path,files{1,i}]);
    h(i,1) = gca;

    errorbarTemp = findobj(h(i,1),'Type','errorbar');
    barTemp = findobj(h(i,1),'Type','bar');
    
    errorReferTable = 1:length(errorbarTemp.YNegativeDelta);
    errorReferTable = transpose(reshape(errorReferTable,[],parameters.numBarActual));
%     errorReferTable = transpose(reshape(1:length(h(i,1).Children(end-parameters.numBarActual*3).YNegativeDelta),[],parameters.numBarActual)); % to know which bar children belong to which bar for error

    % first layer separates different number of feature used in
    % classification, second layer consists of different figures
    for j = 1:parameters.numBarShown
        lineFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual-1)).YData;
        barFeature{j,1}{i,1} = barTemp(end-j+1).YData;
%         meanFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual*2-1)).YData;
        errorBarFeature{j,1}{i,1} = errorbarTemp.YNegativeDelta(errorReferTable(j,:));
        errorBarFeature{j,1}{i,2} = errorbarTemp.YPositiveDelta(errorReferTable(j,:));
%         errorBarFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual*3-1)).YNegativeDelta(errorReferTable(j,:));
%         errorBarFeature{j,1}{i,2} = h(i,1).Children(end-(j+parameters.numBarActual*3-1)).YPositiveDelta(errorReferTable(j,:));
    end
    XNames{i,1} = h(i,1).XTickLabel;
    legendName{i,1} = files{1,i}(1:8); % legend names
    if ~exist('parameters.xTickLabel','var')
        parameters.xTickLabel = h(i,1).XTickLabel;
    end
    close
end

%% Trim
if parameters.trimId{1,1} > 0
    for i = 1:iters
        for j = 1:parameters.numBarShown
            lineFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            barFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            errorBarFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            errorBarFeature{j,1}{i,2}(parameters.trimId{i,1}) = [];
            XNames{i,1}(parameters.trimId{i,1}) = [];
        end
    end
end

%% Plot
close all
% legendName = [legendName; reshape(repmat({'Median','Mean'},2,1),[],1)];
for i = 1:parameters.numBarShown
    titleName = ['Comparison between 1-feature and 2-feature sensitivity accuracies of muscle GC speed ',parameters.legendArray{i,1}];
%     titleName = ['All Classification Acuracies across Days Muscle ',parameters.legendArray{i,1}];
%     titleName = ['Comparison between Raw and ROC accuracies with ',num2str(i),'-D classification'];
    dataBar = transpose(vertcat(barFeature{i,1}{:,1}));
    dataStde = cat(3,transpose(vertcat(errorBarFeature{i,1}{:,1})),transpose(vertcat(errorBarFeature{i,1}{:,2})));
    dataMean = transpose(vertcat(lineFeature{i,1}{:,1}));
    [p,h] = barWithErrorBar(dataBar,dataStde,0,...
        titleName,legendName);
    ylim([0,1])
    xlabel(parameters.xLabelText)
    ylabel(parameters.yLabelText)
    h.XTick = 1:size(dataBar,1);
    h.XTickLabel = parameters.xTickLabel;
%     h.XTickLabel = XNames{i,1};
    
    if parameters.saveBarPlot
        saveas(gcf,[path,filesep,titleName,'.fig']);
        saveas(gcf,[path,filesep,titleName,'.jpg']);
    end
    
end

popMsg('Done :D')

end

