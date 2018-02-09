function [synergyParameters,significance] = calculateSynergy(dataSingle, dataGroup, downSamplingValue)
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

%% Get the 2.5% 97.5% of the distributions
alphaValue = 5; % value to determine the significancy
singleFeatureMaxPartial = prctile(singleFeatureMax',[alphaValue/2 ; 100-alphaValue]);
dataGroupPartial = prctile(dataGroup,[alphaValue/2 ; 100-alphaValue]);
compareMatrix = repmat(singleFeatureMaxPartial,1,2) > repmat(dataGroupPartial',2,1); % a matrix that shows the comparison between each pair of numbers

% there are 6 possible situations in total, the condition is that if the
% two distributions are not totally separated than it will be classified as
% not significant.
if all(compareMatrix(:)) || ~any(compareMatrix(:))
    significance = 1; % not significant
else
    significance = 0; % not significant
end


%% Check Normality (Not fair as multple repetitions due to the bootstriping)
% [llNormalitySingle,llPValueSingle] = lillietest(singleFeatureMaxPartial);  % return 1 to reject the hypothesis that it is normally distributed
% [llNormalityTwo,llPValueTwo] = lillietest(dataGroupPartial);
% 
% [ks2Normality,ks2PValue] = kstest2(singleFeatureMaxPartial,dataGroupPartial); % return 1 to reject the hypothesis that hte 2 samples are drawn from the same underlying continuousu population

end

