function synergyParameters = calculateSynergy(dataSingle, dataGroup, downSamplingValue)
%calculateSynergy Currently support synergy from 2 arrays that can have
%different sizes.
%
% input: data:              Different data should be separated in different rows in cells
%        downSamplingValue: Down sampling if the data size is too large, input 0 to disable.
% 
%   synergyParameters = calculateSynergy(dataSingle, dataGroup, downSamplingValue)

[singleFeatureMesh{1,1},singleFeatureMesh{2,1}] = meshgrid(dataSingle{1,1},dataSingle{2,1});

singleFeatureMax = max(singleFeatureMesh{1,1}, singleFeatureMesh{2,1}); % get the maximum performance with the single feature classification
singleFeatureMax = singleFeatureMax(randperm(downSamplingValue^2,downSamplingValue)); % down size by randomly picking numRepetition from all the combinations of summation

[twoFeatureMesh,singleFeatureMaxMesh] = meshgrid(dataGroup,singleFeatureMax(:));

synergyMesh = twoFeatureMesh - singleFeatureMaxMesh; % get the difference of the max and the combined performance

synergyParameters = getBasicParameter(synergyMesh(:));

%% Check Normality
normalitySingle = lillietest(singleFeatureMaxMesh(:));
normalityTwo = lillietest(twoFatureMesh(:));

end

