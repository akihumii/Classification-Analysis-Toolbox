function outputInfo = combineClassificationOutput()
%COMBINECLASSIFICATIONOUTPUT Combine the classification output generated in
%different .mat files of classifier modles.
% 
%   outputInfo = combineClassificationOutput()

%% Parameters
saveVariables = 1;

%% Read files
[files,path,iter] = selectFiles('Select the mat files to combine their features');

output.classificationOutput = cell(0,1);
output.featureIndex = cell(0,1);

load([path,files{1,1}]); % to load the variables stored in the first .mat file, which will be used as the new combined .mat file later

for i = 1:iter
    info(i,1) = load([path,files{i}]);
    dotLocs = strfind(files{1,i},'.');
    fileNames{i,1} = files{1,i}(1:dotLocs(1,1)-1);
    output.classificationOutput = vertcat(output.classificationOutput, info(i,1).varargin{1,1}.classificationOutput);
    output.featureIndex = vertcat(output.featureIndex, info(i,1).varargin{1,1}.featureIndex);
end

%% output
info(1,1).varargin{1,1}.classificationOutput = output.classificationOutput;
info(1,1).varargin{1,1}.featureIndex = output.featureIndex;

varargin{1,1} = info(1,1).varargin{1,1};

outputInfo = info(1,1);

if saveVariables
    saveVar(path,horzcat(fileNames{:,1}),outputInfo.varargin{:});
end

end

