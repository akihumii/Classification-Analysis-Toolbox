function [] = combineBarPlot()
%EDITBARPLOT Combine the bars in different figures.
%   Detailed explanation goes here

%% Parameters
parameters = struct(...
    'saveBarPlot',1);
parameters.trimId = {[5,10];2}; % will be separated into two structures if they are assigned with 'struct'

%% Select files
[files,path,iters] = selectFiles('Select all the matlab figures to plot the combined plot');

%% Process
for i = 1:iters
    p(i,1) = open([path,files{1,i}]);
    h(i,1) = gca;
    % first layer separates different number of feature used in
    % classification, second layer consists of different figures
    medFeature{1,1}{i,1} = h(i,1).Children(end-2).YData;
    medFeature{2,1}{i,1} = h(i,1).Children(end-3).YData;
    meanFeature{1,1}{i,1} = h(i,1).Children(end-4).YData;
    meanFeature{2,1}{i,1} = h(i,1).Children(end-5).YData;
    errorBarFeature{1,1}{i,1} = h(i,1).Children(end-6).YNegativeDelta(1:end/2);
    errorBarFeature{1,1}{i,2} = h(i,1).Children(end-6).YPositiveDelta(1:end/2);
    errorBarFeature{2,1}{i,1} = h(i,1).Children(end-6).YNegativeDelta(end/2+1:end);
    errorBarFeature{2,1}{i,2} = h(i,1).Children(end-6).YPositiveDelta(end/2+1:end);
    XNames{i,1} = h(i,1).XTickLabel;
    legendName{i,1} = files{1,i}(1:11); % legend names
    close
end

%% Trim
if parameters.trimId{1,1} > 0
    for i = 1:iters
        medFeature{1,1}{i,1}(parameters.trimId{i,1}) = [];
        medFeature{2,1}{i,1}(parameters.trimId{i,1}) = [];
        meanFeature{1,1}{i,1}(parameters.trimId{i,1}) = [];
        meanFeature{2,1}{i,1}(parameters.trimId{i,1}) = [];
        errorBarFeature{1,1}{i,1}(parameters.trimId{i,1}) = [];
        errorBarFeature{1,1}{i,2}(parameters.trimId{i,1}) = [];
        errorBarFeature{2,1}{i,1}(parameters.trimId{i,1}) = [];
        errorBarFeature{2,1}{i,2}(parameters.trimId{i,1}) = [];
        XNames{i,1}(parameters.trimId{i,1}) = [];
    end
end

%% Plot
close all
legendName = [legendName; reshape(repmat({'Median','Mean'},2,1),[],1)];
for i = 1:size(medFeature,1)
    dataBar = transpose(vertcat(medFeature{i,1}{:,1}));
    dataStde = cat(3,transpose(vertcat(errorBarFeature{i,1}{:,1})),transpose(vertcat(errorBarFeature{i,1}{:,2})));
    dataMean = transpose(vertcat(meanFeature{i,1}{:,1}));
    [p,h] = barWithErrorBar(dataBar,dataStde,dataMean,...
        ['Comparison between Raw and ROC accuracies with ',num2str(i),'-D classification'],legendName);
    ylim([0,1])
xlabel('Day')
ylabel('Accuracy')
h.XTickLabel = XNames{i,1};

if parameters.saveBarPlot
    saveas(gcf,['Comparison between Raw and ROC accuracies with ',num2str(i),'-D classification.fig']);
    saveas(gcf,['Comparison between Raw and ROC accuracies with ',num2str(i),'-D classification.jpg']);
end

end

popMsg('Done :D')

end

