function [gaitLocs,gaitStats] = getGaitInfo(fileName,data,foot)
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

gaitStats = array2table(transpose(reshape(vertcat(data{endLocs:endLocs+2, 4:13}),3,[])));
gaitStats.Properties.RowNames = {'Stance','Brake','Propel','Swing','Stride','PercentageOfStance','PercentageOfSwing','StrideLength','AvePrintArea','StancePressure'};
gaitStats.Properties.VariableNames = {['Average',fileName(1:4)],['StdDev',fileName(1:4)],['Median',fileName(1:4)]};
end

