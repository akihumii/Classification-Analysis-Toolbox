function windowsValues = visualizeSignals(signal, signalClassification, odinparam, selectedWindow, windowSize, partialDataSelection, channelExtractStartingLocs, dataToBeDetectedSpike, saveRaw, showRaw, saveDifferential, showDifferential, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)
%visualizeSignal Visualize needed signals. Raw, filtered, differential,
%overlapping windows, average windows, and overall signal with indicated
%spikes can be plotted.
% Average window will be show/save according to the input of
% 'showOverlap/saveOverlap'.
% Overall signal with spikes indicated will be show only when the input
% 'showOverlap' is 1 and will not be saved.
%   [] = visualizeSignals(signal, signalClassification, selectedWindow, windowSize, saveRaw, showRaw, saveDelta, showDelta, saveRectified, showRectified, saveFilt, showFilt, saveOverlap, showOverlap, saveFFT, showFFT)

%% Partial Data Selectiom
for i = 1:length(signal)
    if partialDataSelection
        partialDataStartingTime{i,1} = [' (',num2str(signal(i,1).time(1) / signal(i,1).samplingFreq)];
        partialDataEndTime{i,1} = [' - ', num2str(signal(i,1).time(end) / signal(i,1).samplingFreq), ' s) '];
    else
        partialDataStartingTime{i,1} = '';
        partialDataEndTime{i,1} = '';
    end
end

%% Plot raw signal
if ~saveRaw && ~showRaw
else
    for i = 1:length(signal)
            % Generate square pulse
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            %% Plotting
            plotAddressFlag = ismember(13, signal(i,1).channel);
            outputSW = generateSquarePulse(signal(i,1).dataAll(:,[13:15]), signal(i,1).samplingFreq, odinparam); 
            shortTimeTemp = repmat(signal(i,1).time/signal(i,1).samplingFreq,length(signal(i,1).channel(signal(i,1).channel<16)),1);
            timeTemp = cell(0,1);
            dataTemp = cell(0,1);
            numChannels = length(signal(i,1).channel);
            for j = 1:size(shortTimeTemp,1)
                timeTemp = [timeTemp;{shortTimeTemp(j,:)}];
                switch odinparam.plotData
                    case 'dataRaw'
                        dataTemp = [dataTemp;{signal(i,1).dataRaw(:,j)}];
                    case 'dataFiltered'
                        dataTemp = [dataTemp;{signal(i,1).dataFiltered.values}];
                    otherwise
                        error('Invalid odinparam.plotData...')
                end
            end
            
            % plot stimulation
            if odinparam.squareAmplitudePlot
                for j = 1:size(outputSW.squareWave,2)
                    timeTemp = [timeTemp;{outputSW.squareWaveTime}];
                    dataTemp = [dataTemp;{outputSW.squareWave(:,j)}];
                end
            end
            
%             timeTemp = [timeTemp;timeTemp(1,1)]; % for color inspection of the change of commands
%             dataTemp = [dataTemp;nan(size(timeTemp{1,1}))]; 
            
            timeTemp = cell2nanMat(timeTemp);
            dataTemp = cell2nanMat(dataTemp);
            
            pSW = plotFig(timeTemp,dataTemp,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Raw Signal','Time(s)',odinparam.ylabel,...
                saveRaw,... % save
                showRaw,... % show
                signal(i,1).path,'subplot', [signal(i,1).channel, signal(i,1).channel(~ismember(signal(i,1).channel, [13,14]))]);
            
            % plot lines
            colorArray = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880;0.3010,0.7450,0.9330;0.6350,0.0780,0.1840;0,0,0];
            
            numPlot = length(pSW);
            
            % plot the colors for special numbers while changing commands
            if odinparam.plotStem
                numSpecialNumber = length(odinparam.specialNumbers);
                for j = 1:numSpecialNumber
                    locsTemp = find(signal(i,1).dataAll(:,13) == odinparam.specialNumbers(j));
                    axes(pSW(2,1));
                    pStem(j,1) = stem(locsTemp/signal(i,1).samplingFreq,255*ones(length(locsTemp),1),'Color',colorArray(j,:));
                    hold on
                end
            end
            
            % Replot 2nd subplot
            if plotAddressFlag
                axes(pSW(2,1))
                plot(pSW(2,1).Children(end,1).XData,pSW(2,1).Children(end,1).YData,'Color','k');
            end
            
            % Add lines into the plots except the simulation plots
%             numLines = size(outputSW.changeLocs,1);
            
            for j = 1:numChannels
                axes(pSW(j,1));
                if plotAddressFlag && j == 2
                    ylim([0,300])
                end
                yLimit = ylim;

                hold on
                grid minor
%                 line{1,j} = plot(repmat(outputSW.chStartingTime(:,1)',2,1),ylim,'-.','color',colorArray(1,:),'lineWidth',1.5);
%                 plot(repmat(outputSW.chEndTime(:,1)',2,1),ylim,'-.','color',colorArray(1,:),'lineWidth',1.5);

                % start channels colorful lines
                if any(ismember([13,14], signal(i,1).channel(j)))
                    for k = 1:length(odinparam.chStartingRef)
                        if ~isempty(outputSW.chStartingTime(:,k)')
                            plot(repmat(outputSW.chStartingTime(:,k)',2,1),ylim,'-.','color',colorArray(k,:),'lineWidth',1.5);
                            plot(repmat(outputSW.chEndTime(:,k)',2,1),ylim,'-.','color',colorArray(k,:),'lineWidth',1.5);
                        end
                    end
                else
                    plot(repmat(outputSW.chStartingTime(:,j)',2,1),ylim,'-.','color',colorArray(j,:),'lineWidth',1.5);
                    plot(repmat(outputSW.chEndTime(:,j)',2,1),ylim,'-.','color',colorArray(j,:),'lineWidth',1.5);
                end
                
%                 if numLines > 0
%                     % changing amplitude lines
% %                     lineAmp{j,1} = plot(repmat(outputSW.changeLocsTime(:,1)',2,1),ylim,'-.','color',[0,100/255,0],'lineWidth',1.5);
%                     
%                     % Text
%                     for k = 1:numLines
%                         text(repmat(outputSW.changeLocsTime(k,1)',2,1)+1e-3,repmat(yLimit(1),1,2),num2str(outputSW.amplitude(k,1)));
%                     end
%                 end
            end
            
            
%             for j = 1:numPlot-2 % pressure sensor plot
                if ~isnan(odinparam.horzLineValue)
                    axes(pSW(1))
                    pHorzLine = plot(xlim,[odinparam.horzLineValue,odinparam.horzLineValue], 'k'); % plot a threshold
                end
%                 legend(pHorzLine,'threshold');
%             end
            
            if plotAddressFlag
                for j = numPlot-1 : numPlot % to select sync pulses plots when no channels plots showing
                    axes(pSW(j))
                    ylabel('Decimal Value')
                end
            end

            if odinparam.squareAmplitudePlot % channel plots
                for j = numChannels+1 : length(pSW)
                    axes(pSW(j,1));
                    grid minor;
                    set(pSW(j,1).Children,'color',colorArray(j-numChannels,:));
                    ylabel('Amplitudes (mA)')
                    title(sprintf('Current Amplitudes channel %d', signal(i,1).channel(j-numChannels)))
                end
            end
            
            % Legend the plots
%             axes(pSW(2,1))
%             
%             for j = 1:size(line,1)
%                 if ~isempty(line{j,2})
%                     legendLine(j,1) = line{j,2}(1,1);
%                 end
%             end
%             if ~isempty(line{1,2})
%                 legend(legendLine,odinparam.legendName(1:length(odinparam.chStartingRef)));
%             end
    end
end

%% Plot rectified signal
if ~saveRectified && ~showRectified
else
    for i = 1:length(signal)
        plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataRectified,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Rectified Signal (High Pass Filtered 1 Hz)','Time(s)','Amplitude(V)',...
            saveRectified,... % save
            showRectified,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
    end
end

%% Plot differential signal
if ~saveDifferential && ~showDifferential
else
    for i = 1:length(signal)
        if isempty(signal(i,1).channelPair)
            if saveDifferential == 1 || showDifferential == 1
                warning('ChannelRef is not keyed in...')
            end
        else
            plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataDifferential,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],'Differential Signal Channel','Time(s)','Amplitude(V)',...
                saveDifferential,... % save
                showDifferential,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
        end
    end
end

%% Plot filtered signal
if ~saveFilt && ~showFilt
else
    if signal(i,1).dataFiltered.highPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.lowPassCutoffFreq ~= 0 || signal(i,1).dataFiltered.notchFreq ~= 0
        for i = 1:length(signal)
            plotFig(signal(i,1).time/signal(i,1).samplingFreq,signal(i,1).dataFiltered.values,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Filtered Signal (', num2str(signal(i,1).dataFiltered.highPassCutoffFreq),'-', num2str(signal(i,1).dataFiltered.lowPassCutoffFreq), ')'],'Time(s)','Amplitude(V)',...
                saveFilt,... % save
                showFilt,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
        end
    end
end

%% Plot FFT signal
if ~saveFFT && ~showFFT
else
    for i = 1:length(signal)
        plotFig(signal(i,1).dataFFT.freqDomain,signal(i,1).dataFFT.values,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],[signal(i,1).dataFFT.dataBeingProcessed,' FFT Signal'],'Frequency(Hz)','Amplitude',...
            saveFFT,... % save
            showFFT,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
    end
end

%% Plot windows following stimulation artefacts
if ~saveOverlap && ~showOverlap
    windowsValues = nan;
else
    for i = 1:length(signalClassification)
        %% Plot the data for peak detection
        if isequal(dataToBeDetectedSpike, 'dataFiltered') || isequal(dataToBeDetectedSpike, 'dataTKEO')
            dataToBeDetectedSpike = [{dataToBeDetectedSpike};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValuesPeakDetection, dataNamePeakDetection] = loadMultiLayerStruct(signal(i,1),dataToBeDetectedSpike);
        
        numChannel = size(signalClassification(i,1).burstDetection.spikeLocs,2);
        overallP = plotFig(signal(i,1).time/signal(i,1).samplingFreq,dataValuesPeakDetection,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Signal used for Peak Detection (', dataNamePeakDetection, ')'],'Time(s)','Amplitude(V)',...
            0,... % save
            1,... % show
            signal(i,1).path,'subplot', signal(i,1).channelPair);
        hold on
        
        % Plot the markings
        for j = 1:numChannel
            plotMarkings(overallP(j,1), signal(i,1).time/signal(i,1).samplingFreq, dataValuesPeakDetection(:,j), signalClassification(i,1).burstDetection.spikeLocs(:,j), signalClassification(i,1).burstDetection.burstEndLocs(:,j), signalClassification(i,1).burstDetection.threshold(j,1))
        end
        
        %% Plot Overlapping Signals
        if isequal(selectedWindow, 'dataFiltered') || isequal(selectedWindow, 'dataTKEO')
            selectedWindow = [{selectedWindow};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
        end
        
        [dataValues, dataName] = loadMultiLayerStruct(signal(i,1),selectedWindow); % get the values and the name of the selected window
        
        maxBurstLength = max(signalClassification(i,1).burstDetection.burstEndLocs - signalClassification(i,1).burstDetection.spikeLocs,[],1);
        
        windowsValues = getPointsWithinRange(...
            signal(i,1).time/signal(i,1).samplingFreq,...
            dataValues,...
            signalClassification(i,1).burstDetection.spikeLocs,...
            signalClassification(i,1).burstDetection.spikeLocs + repmat(maxBurstLength*1.5,size(signalClassification(i,1).burstDetection.spikeLocs,1),1),...
            windowSize, signal(i,1).samplingFreq, channelExtractStartingLocs);
        
        % Get all windows in same plots
        %         windowsValues.xAxisValues = reshape(windowsValues.xAxisValues,[],2*size(windowsValues.xAxisValues,2));
        %         windowsValues.burst = reshape(windowsValues.burst,[],2*size(windowsValues.burst,2));
        
        % Plot overlapping windows
        plotFig(windowsValues.xAxisValues,windowsValues.burst,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Windows Following Artefacts ( ', dataName, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair);
        
        % plot averaging overlapping windows
        plotFig(windowsValues.xAxisValues,nanmean(windowsValues.burst,2),[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Average Windows Following Artefacts ( ', dataName, ' )'],'Time(s)','Amplitude(V)',...
            saveOverlap,... % save
            showOverlap,... % show
            signal(i,1).path,'overlap', signal(i,1).channelPair);
        
        % plot overall signal with spikes indicated
        if showOverlap || saveOverlap
            overallP = plotFig(signal(i,1).time/signal(i,1).samplingFreq,dataValues,[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],['Overall Signal with Spikes Indicated (', dataName, ')'],'Time(s)','Amplitude(V)',...
                0,... % save
                1,... % show
                signal(i,1).path,'subplot', signal(i,1).channelPair);
            hold on
            
            % Plot the markings
            for j = 1:numChannel
                plotMarkings(overallP(j,1), signal(i,1).time/signal(i,1).samplingFreq, dataValues(:,j), signalClassification(i,1).burstDetection.spikeLocs(:,j), signalClassification(i,1).burstDetection.burstEndLocs(:,j), nan)
            end
            
            % Save
            if saveOverlap
                savePlot(signal(i,1).path,['Overall Signal with Spikes Indicated (', dataName, ')'],[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}],[signal(i,1).fileName,partialDataStartingTime{i,1},partialDataEndTime{i,1}])
            end
            if ~showOverlap
                close gcf
            end
        end
    end
end
end

