function [gaitLocs,path] = readGait()
%readGait Read the gait and output the location in sample points
%   [gaitLocs,path] = readGait()

[files,path] = selectFiles('select gait data excel file');

[num, txt, raw] = xlsread([path,files{1}],'List');

numRow = size(raw(:,1));

for i = 1:numRow
    if isequal(raw{i,1},'Rear Left');
        startLocs = i+1;
    end
    
    if isequal(raw{i,1},'Foot Spacing Info')
        endLocs = i-1;
        break
    end
end

content = cell2mat(raw(startLocs:endLocs,1:2)); % locations in numbers in matrix form

gaitLocs = content(~isnan(content)); % a tall matrix 
gaitLocs = reshape(gaitLocs,[],2); % a matrix with 2 columns indicating starting and end locations
gaitLocs = gaitLocs / 100; % convert into seconds

end

