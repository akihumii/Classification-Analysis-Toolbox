function output = getFeaturesInfo(path,files)
%getFeaturesInfo Get the features information from the saved mat files
%after running mainClassifier.m
%
% output:   saveFileName,signal,signalClassification,fileName, features, fileSpeed,
% fileDate, dataFiltered, dataTEKO, samplingFreq, detectionInfo
%
%   output = getFeaturesInfor(path,files

info = load([path,files]);
output.saveFileName = files(1:end-4);
output.signal = info.varargin{1,1};
output.signalClassification = info.varargin{1,2};
output.windowsValues = info.varargin{1,3};

output.fileName = output.signal.fileName;
output.features = output.signalClassification.features;
% output.fileSpeed{1,1} = output.fileName(7:8);
% output.fileDate{1,1} = output.fileName(12:17);
% output.fileSpeed{1,1} = files(22:23);
% output.fileDate{1,1} = files(6:13);
output.fileSpeed{1,1} = files(5:6);
output.fileDate{1,1} = files(10:17);

output.dataFiltered = output.signal.dataFiltered.values;
output.dataTKEO = output.signal.dataTKEO.values; % signals for discrete classifcation
output.samplingFreq = output.signal.samplingFreq;
output.detectionInfo = output.signalClassification.burstDetection;
end

