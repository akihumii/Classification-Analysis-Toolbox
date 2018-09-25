function [gaitLocs,gaitStatsAve,gaitStatsStd,gaitStatsMed] = getGaitInfo(fileName,data,foot)
%GETGAITINFO Get the information of the specified foot
%   [gaitLocs,gaitStats] = getGaitInfo(data,foot)

for i = 1:size(data(:,1))
    if isequal(data{i,1},foot) % find the starting location of the foot data
        startLocs = i+1;
        endLocs = startLocs;
        while ~isequal(data{endLocs,3},'       Average:') % find the end location of the foot data
            endLocs = endLocs + 1;
        end
        break
    end
end

gaitLocs = cell2mat(data(startLocs:endLocs,1:2)); % locations in numbers in matrix form
gaitLocs = squeezeNan(gaitLocs,2); % a tall matrix 
gaitLocs = gaitLocs / 100; % convert into seconds

gaitStatsAll = transpose(reshape(vertcat(data{endLocs:endLocs+2, 4:13}),3,[]));
gaitStatsAve = array2table(gaitStatsAll(:,1));
gaitStatsStd = array2table(gaitStatsAll(:,2));
gaitStatsMed = array2table(gaitStatsAll(:,3));

gaitStatsAve.Properties.RowNames = {'Stance','Brake','Propel','Swing','Stride','PercentageOfStance','PercentageOfSwing','StrideLength','AvePrintArea','StancePressure'};
gaitStatsStd.Properties.RowNames = {'Stance','Brake','Propel','Swing','Stride','PercentageOfStance','PercentageOfSwing','StrideLength','AvePrintArea','StancePressure'};
gaitStatsMed.Properties.RowNames = {'Stance','Brake','Propel','Swing','Stride','PercentageOfStance','PercentageOfSwing','StrideLength','AvePrintArea','StancePressure'};

gaitStatsAve.Properties.VariableNames = {['Average',fileName(1:4)]};
gaitStatsStd.Properties.VariableNames = {['StdDev',fileName(1:4)]};
gaitStatsMed.Properties.VariableNames = {['Median',fileName(1:4)]};
end

