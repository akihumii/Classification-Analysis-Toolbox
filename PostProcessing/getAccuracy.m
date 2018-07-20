function [] = getAccuracy()
%GETACCURACY Get the accuracy from multiple trained classifier models
% 
%   [] = getAccuracy()

saveData = 1;

[files,path,iters] = selectFiles('Select the trained classifier model');

disp('Processing...')

for i = 1:iters
    dataTemp(i,1) = load(fullfile(path,files{1,i}));
    accuracyMax{i,1} = dataTemp(i,1).varargin{1,1}.accuracyMax;
end

[numDimensionClassification, numChannel] = size(accuracyMax{1,1});
for i = 1:numDimensionClassification
    for j = 1:numChannel
        legendName{i,j} = ['Dim',num2str(i),'Classification','Channel',num2str(j)];
        
        allAccuracy{i,j} = zeros(0,1);
        for k = 1:iters
            allAccuracy{i,j} = vertcat(allAccuracy{i,j},accuracyMax{k,1}(i,j));
        end
    end
end

accuracyTable = array2table([transpose(1:iters),horzcat(allAccuracy{:,:})],'VariableNames',[{'FileID'},legendName(:)']);

if saveData
    writetable(accuracyTable,fullfile(path,['summaryTable',time2string]));
end

disp('Finish...')

end

