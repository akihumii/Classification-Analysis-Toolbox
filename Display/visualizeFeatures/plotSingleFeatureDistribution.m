function [] = plotSingleFeatureDistribution(numChannel,numFeatures,featuresInfo,plotFileName,path,channel,numClass,colorArray,classifierOutput,numRowSubplots,xTickValue,xScale,displayInfo)
%plotSingleFeatureDistribution Plot distribution of single feature in
%visualizeFeatures
% 
%   plotSingleFeatureDistribution(numChannel,numFeatures,featuresInfo,plotFileName,path,channel,numClass,colorArray,classifierOutput,numRowSubplots,xTickValue,xScale,displayInfo)

    for i = 1:numChannel
        for j = 1:numFeatures
            featuresTemp = cell2nanMat(featuresInfo.featuresAll(:,j,i)); % reconstruct the same features from all classes into a matrix
            [pHist(j,i),fHist(j,i),hHist] = plotFig(0,featuresTemp,plotFileName,['Distribution of ',featuresInfo.featuresNames{j,1}],'','Amplitudes',0,1,path,'overlap',channel(1,i),'histFitPlot'); % plot the histogram with fit distribution the feature of each class
            hold on
            for k = 1:numClass
                hHist{k,1}(1,1).FaceColor = colorArray(k,:);
                hHist{k,1}(2,1).Color = colorArray(k,:);
                hHistTemp(k,1) = hHist{k,1}(2,1);
            end
            l(j,i) = legend(hHistTemp,xTickValue);
            
            % plot classifier's boundary
            constTemp(1,1) = classifierOutput.classificationOutput{1,1}(j,1).coefficient{i,1}(1,2).const; % first and second class constant
            linearTemp(1,:) = classifierOutput.classificationOutput{1,1}(j,1).coefficient{i,1}(1,2).linear; % first and second class linear
            plotBoundary(pHist(j,i),constTemp,linearTemp);
        end
    end
    % plot all the graphs in a same figure
    for i = 1:numChannel
        [~,fSHist(i,1)] = plots2subplots(pHist(:,i),numRowSubplots,numFeatures/numRowSubplots);
        pHistTemp = gca;
        legend(flipud(pHistTemp.Children(1:2:end,1)),[xTickValue;{'Classifier''s boudary'}]);
        if displayInfo.saveHistFit
            savePlot(path,'Distribution of Features',plotFileName,['Distribution of features of channel ',num2str(channel(1,i)),' with ',xScale,' ',checkMatNAddStr(xTickValue,',')])
        end
        if ~displayInfo.showHistFit
            close
        end
    end
    delete(fHist) % delete the separated plot
    clear featuresTemp numFeatures constantTemp linearTemp

end

