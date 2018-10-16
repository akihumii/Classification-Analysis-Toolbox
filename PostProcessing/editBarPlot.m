function [] = editBarPlot()
%EDITBARPLOT Combine the bars in different figures.
%   Detailed explanation goes here

%% Parameters
parameters = struct(...
    'numBarShown',1,...
    'numBarActual',2,...
    'xLabelText','Day',...
    'yLabelText','Accuracy',...
    'saveBarPlot',1);
parameters.trimId = {0};
% parameters.trimId = {[5,10];2}; % will be separated into two structures if they are assigned with 'struct'

%% Select files
[files,path,iters] = selectFiles('Select all the matlab figures to plot the combined plot');

%% Process
for i = 1:iters
    
    p(i,1) = open([path,files{1,i}]);
    h(i,1) = gca;

    errorReferTable = transpose(reshape(1:length(h(i,1).Children(end-parameters.numBarActual*3).YNegativeDelta),[],parameters.numBarActual)); % to know which bar children belong to which bar for error

    % first layer separates different number of feature used in
    % classification, second layer consists of different figures
    for j = 1:parameters.numBarShown
        medFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual-1)).YData;
        meanFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual*2-1)).YData;
        errorBarFeature{j,1}{i,1} = h(i,1).Children(end-(j+parameters.numBarActual*3-1)).YNegativeDelta(errorReferTable(j,:));
        errorBarFeature{j,1}{i,2} = h(i,1).Children(end-(j+parameters.numBarActual*3-1)).YPositiveDelta(errorReferTable(j,:));
    end
    XNames{i,1} = h(i,1).XTickLabel;
    legendName{i,1} = files{1,i}(1:11); % legend names
    close
end

%% Trim
if parameters.trimId{1,1} > 0
    for i = 1:iters
        for j = 1:parameters.numBarShown
            medFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            meanFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            errorBarFeature{j,1}{i,1}(parameters.trimId{i,1}) = [];
            errorBarFeature{j,1}{i,2}(parameters.trimId{i,1}) = [];
            XNames{i,1}(parameters.trimId{i,1}) = [];
        end
    end
end

%% Plot
close all
legendName = [legendName; reshape(repmat({'Median','Mean'},2,1),[],1)];
for i = 1:parameters.numBarShown
    titleName = ['Comparison between Raw and ROC accuracies with ',num2str(i),'-D classification'];
    dataBar = transpose(vertcat(medFeature{i,1}{:,1}));
    dataStde = cat(3,transpose(vertcat(errorBarFeature{i,1}{:,1})),transpose(vertcat(errorBarFeature{i,1}{:,2})));
    dataMean = transpose(vertcat(meanFeature{i,1}{:,1}));
    [p,h] = barWithErrorBar(dataBar,dataStde,0,...
        titleName,legendName);
    ylim([0,1])
    xlabel(parameters.xLabelText)
    ylabel(parameters.yLabelText)
    h.XTickLabel = XNames{i,1};
    
    if parameters.saveBarPlot
        saveas(gcf,[path,filesep,titleName,'.fig']);
        saveas(gcf,[path,filesep,titleName,'.jpg']);
    end
    
end

popMsg('Done :D')

end

