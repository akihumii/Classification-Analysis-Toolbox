function [dataBar,dataStde,dataMean] = combineBars(dataBar,dataStde,dataMean)
%COMBINEBARS It is used in editBarPlot function to combine the barf info
%for plotting
%   Detailed explanation goes here
    dataBar = transpose(vertcat(dataBar));
    dataStde = cat(3,transpose(vertcat(dataStde{:,1})),transpose(vertcat(dataStde{:,2})));
    dataMean = transpose(vertcat(dataMean));

end

