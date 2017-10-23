%% Run Classification with two classes

clear
close all

%% select files
[files, path, iter] = selectFiles;

featureClassOne = load([path,'current 1']);
featureClassTwo = load([path,'current 2']);
features.classOne = featureClassOne.features{1}.classOne;
features.classTwo = featureClassTwo.features{1}.classOne;

classificationOutput = classification(features);
display(['performance = ',num2str(classificationOutput.accuracy{1,1}.accuracy)])
display(['const = ', num2str(classificationOutput.coefficient{1,1}(1,2).const)])
display(['linear =  ', num2str(classificationOutput.coefficient{1,1}(1,2).linear)])
