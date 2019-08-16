function [] = getSVMLoss(features, class)
%GETSVMLOSS Check cross validation loss of the features.
%   Detailed explanation goes here
SVMModel = fitcsvm(features, class, 'Standardize', true);
end

