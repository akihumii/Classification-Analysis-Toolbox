function [] = plotMultipleFeatureDistribution(numChannel,featuresInfo,plotFileName,channel,path,featureIndex,classifierOutput,xTickValue,displayInfo,numClass,colorArray)
%plotMultipleFeatureDistribution Plot multiple feature distribution in
%visualizeFeatures
% 
%   [] = plotMultipleFeatureDistribution(numChannel,featuresInfo,plotFileName,channel,path,featureIndex,classifierOutput,xTickValue,displayInfo,numClass,colorArray)

    featureIndexTemp = [1,3;1,3]; % features used in combinations, channels are separated in rows
    for i = 1:numChannel
        for j = 1:2
            featuresTemp{j,1} = featuresInfo.featuresAll(:,featureIndexTemp(i,j),i);
            featuresTemp{j,1} = cell2nanMat(featuresTemp{j,1});
        end
        pScatter = plotFig(featuresTemp{1,1},featuresTemp{2,1},plotFileName,['Distribution of 2 Features ( ',checkMatNAddStr(featuresInfo.featuresNames(featureIndexTemp(i,:)),' , '),' ) of ',plotFileName,' ch ',num2str(channel(1,i))],featuresInfo.featuresNames(featureIndexTemp(i,1)),featuresInfo.featuresNames(featureIndexTemp(i,2)),0,1,path,'overlap',channel(1,i),'scatterPlot'); % plot the scattered points distribution of the feature of each class;
        hold all
        grid on
        
        numFeatures = size(featureIndex{2,1},1);
        featuresLocsTemp = repmat(featureIndexTemp(i,:),numFeatures,1) == featureIndex{2,1};
        featuresLocsTemp = find(all(featuresLocsTemp,2));
        
        constTemp(1,1) = classifierOutput.classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).const; % first and second class constant
        linearTemp(1,:) = classifierOutput.classificationOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,2).linear; % first and second class linear
        if numClass > 2
            constTemp(2,1) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).const; % second and third class constant
            linearTemp(2,:) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(2,3).linear; % second and third class linear
            constTemp(3,1) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).const; % first and third class constant
            linearTemp(3,:) = classifierOutput{2,1}(featuresLocsTemp,1).coefficient{i,1}(1,3).linear; % first and third class linear
        end
        plotBoundary(pScatter,constTemp,linearTemp);
        
        lineTemp = gca;
        lineTemp = flipud(lineTemp.Children(1:(numClass*(numClass-1)/2)));
        for j = 1:length(lineTemp)
            lineTemp(j,1).Color = colorArray(j,:);
        end
        
        if numClass == 2
            legend(flipud(pScatter.Children),xTickValue{:},checkMatNAddStr(xTickValue(:,1),' , '));
        elseif numClass == 3
            legend(flipud(pScatter.Children),xTickValue{:},checkMatNAddStr(xTickValue(1:2,1),' , '),checkMatNAddStr(xTickValue(2:3,1),' , '),checkMatNAddStr(xTickValue([1,3],1),' , '));
        end
        
        if displayInfo.saveHistFit
            savePlot(path,'Distribution of 2 Features',plotFileName,['Distribution of features ( ',checkMatNAddStr(featuresInfo.featuresNames(featureIndexTemp(i,:)),' , '),' )  of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        
    end
end

