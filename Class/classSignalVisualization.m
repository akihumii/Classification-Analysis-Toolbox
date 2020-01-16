classdef classSignalVisualization < handle
    %CLASSSIGNALVISUALIZATION Used in mainClassifier to visualize signals
    %   can directly run the class construction and the rest will be run
    %   automatically
    %   windowsValues = visualizeSignals(obj.signal, obj.signalClassification,
    %   obj.rasterLocs, obj.parameters, obj.PP)
    
    
    properties
        signal
        signalClassification
        rasterLocs
        parameters
        PP
        
        partialDataStartingTime
        partialDataEndTime
        titleRaw = 'Raw obj.signal'
        titleFiltered
        windowsValues
    end
    
    %%
    methods (Access = public)
        function [obj, windowsValues] = classSignalVisualization(signal, signalClassification, rasterLocs, parameters, PP)
            obj.signal = signal;
            obj.signalClassification = signalClassification;
            obj.rasterLocs = rasterLocs;
            obj.parameters = parameters;
            obj.PP = PP;
            
            obj.setPlottingParameters();
            obj.selectPartialData();
            
            % Plot raw obj.signal
            obj.titleRaw = 'Raw obj.signal';
            if obj.parameters.saveRaw || obj.parameters.showRaw
                obj.plotRawSignal();
            end
            
            % Plot rectified obj.signal
            if obj.parameters.saveRectified || obj.parameters.showRectified
                obj.plotRectifiedSignal();
            end
            
            % Plot differential obj.signal
            if obj.parameters.saveDifferential || obj.parameters.showDifferential
                obj.plotDifferentialSignal();
            end
            
            % Plot filtered obj.signal
            obj.titleFiltered = ['Filtered obj.signal (', num2str(obj.signal(1,1).dataFiltered.highPassCutoffFreq),'-', num2str(obj.signal(1,1).dataFiltered.lowPassCutoffFreq), ')'];
            if obj.parameters.saveFilt || obj.parameters.showFilt
                obj.plotFilteredSignal();
            end
            
            % Plot FFT obj.signal
            if obj.parameters.saveFFT || obj.parameters.showFFT
                obj.plotFFTSignal();
            end
            
            % Plot windows following stimulation artefacts
            if ~obj.parameters.noClassification
                % Plot the data for peak detection
                obj.plotPeakDetectionSignal();
                
                if parameters.showDetectedBursts
                    obj.plotDetectedBursts();
                end
                
                % Plot Overlapping Signals
                if obj.parameters.showOverlap || obj.parameters.saveOverlap
                    obj.plotOverlappingSignal();
                end
                
                % plot overall obj.signal with spikes indicated
                if obj.parameters.showOverall || obj.parameters.saveOverall
                    obj.plotOverallSignal();
                end
            end
            
            % Plot comparison
            if obj.parameters.showCompare || obj.parameters.saveCompare
                obj.plotComparisonSignal();
            end
            
            % Plot raster plot
            if obj.parameters.saveRaster || obj.parameters.showRaster
                obj.plotRasterPlot();
            end
            
            
            windowsValues = nan(length(obj.signalClassification),1);
            
        end
        %% Function
        function selectPartialData(obj)
            for i = 1:length(obj.signal)
                if obj.parameters.partialDataSelection
                    obj.partialDataStartingTime{i,1} = [' (',num2str(obj.signal(i,1).time(1) / obj.signal(i,1).samplingFreq)];
                    obj.partialDataEndTime{i,1} = [' - ', num2str(obj.signal(i,1).time(end) / obj.signal(i,1).samplingFreq), ' s) '];
                else
                    obj.partialDataStartingTime{i,1} = '';
                    obj.partialDataEndTime{i,1} = '';
                end
            end
        end
        
        function setPlottingParameters(obj)
            obj.PP.overlappingYMult = obj.getAxisMultiplier(obj.PP.overlappingYUnit);
            obj.PP.filteredYMult = obj.getAxisMultiplier(obj.PP.filteredYUnit);
            obj.PP.rawYMult = obj.getAxisMultiplier(obj.PP.rawYUnit);
            obj.PP.overallYMult = obj.getAxisMultiplier(obj.PP.overallYUnit);
            obj.PP.averageYMult = obj.getAxisMultiplier(obj.PP.averageYUnit);
            
            if ~strcmp(obj.PP.overlappingYLimit,'auto'); obj.PP.overlappingYLimit = obj.PP.overlappingYMult * obj.PP.overlappingYLimit; end
            if ~strcmp(obj.PP.filteredYLimit, 'auto'); obj.PP.filteredYLimit = obj.PP.filteredYMult * obj.PP.filteredYLimit; end
            if ~strcmp(obj.PP.rawYLimit, 'auto'); obj.PP.rawYLimit = obj.PP.rawYMult * obj.PP.rawYLimit; end
            if ~strcmp(obj.PP.overallYLimit, 'auto'); obj.PP.overallYLimit = obj.PP.overallYMult * obj.PP.overallYLimit; end
            if ~strcmp(obj.PP.averageYLimit, 'auto'); obj.PP.averageYLimit = obj.PP.averageYMult * obj.PP.averageYLimit; end
        end
        
        function plotRawSignal(obj)
            for i = 1:length(obj.signal)
                [dataTemp, channelTemp] = obj.bindSyncNCounter(obj.PP.rawYMult*obj.signal(i,1).dataRaw, obj.parameters, obj.signal(i,1));
                plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],obj.titleRaw,'Time (s)','Amplitude (V)',obj.parameters.saveRaw,obj.parameters.showRaw,obj.signal(i,1).path,'subplot', channelTemp, 'linePlot', obj.PP.rawYLimit);
            end
        end
        
        function plotRectifiedSignal(obj)
            for i = 1:length(obj.signal)
                [dataTemp, ~] = obj.bindSyncNCounter(obj.signal(i,1).dataRectified, obj.parameters, obj.signal(i,1));
                plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],'Rectified obj.signal (High Pass Filtered 1 Hz)','Time (s)','Amplitude (V)',obj.parameters.saveRectified,obj.parameters.showRectified,obj.signal(i,1).path,'subplot', obj.signal(i,1).channelTemp);
            end
        end
        
        function plotDifferentialSignal(obj)
            for i = 1:length(obj.signal)
                if isempty(obj.signal(i,1).channelPair)
                    if obj.parameters.saveDifferential == 1 || obj.parameters.showDifferential == 1
                        warning('ChannelRef is not keyed in...')
                    end
                else
                    [dataTemp, channelTemp] = obj.bindSyncNCounter(obj.signal(i,1).dataDifferential, obj.parameters, obj.signal(i,1));
                    plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],'Differential obj.signal Channel','Time(s)','Amplitude (V)',obj.parameters.saveDifferential,obj.parameters.showDifferential,obj.signal(i,1).path,'subplot', channelTemp);
                end
            end
        end
        
        function plotFilteredSignal(obj)
            if obj.signal(1,1).dataFiltered.highPassCutoffFreq ~= 0 || obj.signal(1,1).dataFiltered.lowPassCutoffFreq ~= 0 || obj.signal(1,1).dataFiltered.notchFreq ~= 0
                for i = 1:length(obj.signal)
                    [dataTemp, channelTemp] = obj.bindSyncNCounter(obj.PP.filteredYMult*obj.signal(i,1).dataFiltered.values, obj.parameters, obj.signal(i,1));
                    plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],obj.titleFiltered,'Time (s)',['Amplitude (',obj.PP.filteredYUnit,')'],obj.parameters.saveFilt,obj.parameters.showFilt,obj.signal(i,1).path,'subplot', channelTemp,'linePlot',obj.PP.filteredYLimit);
                end
            else
                popMsg('No cutoff frequencies have been applied, so not plotting filtered signals...');
            end
        end
        
        function plotFFTSignal(obj)
            for i = 1:length(obj.signal)
                [dataTemp, channelTemp] = obj.bindSyncNCounter(obj.signal(i,1).dataFFT.values, obj.parameters, obj.signal(i,1));
                plotFig(obj.signal(i,1).dataFFT.freqDomain,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],[obj.signal(i,1).dataFFT.dataBeingProcessed,' FFT obj.signal'],'Frequency (Hz)','Amplitude',obj.parameters.saveFFT,obj.parameters.showFFT,obj.signal(i,1).path,'subplot', channelTemp);
            end
        end
        
        function plotPeakDetectionSignal(obj)
            for i = 1:length(obj.signalClassification)
                
                if isequal(obj.parameters.dataToBeDetectedSpike, 'dataFiltered') || isequal(obj.parameters.dataToBeDetectedSpike, 'dataTKEO')
                    obj.parameters.dataToBeDetectedSpike = [{obj.parameters.dataToBeDetectedSpike};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
                end
                
                [dataValuesPeakDetection, dataNamePeakDetection] = loadMultiLayerStruct(obj.signal(i,1),obj.parameters.dataToBeDetectedSpike);
                
                numChannel = size(obj.signalClassification(i,1).burstDetection.spikeLocs,2);
                if obj.parameters.showInverseFlag
                    signPlot = -1;
                else
                    signPlot = 1;
                end
                overallP = plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,signPlot*dataValuesPeakDetection,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],['obj.signal used for Peak Detection (', dataNamePeakDetection, ')'],'Time (s)','Amplitude (\muV)',...
                    0,... % save
                    1,... % show
                    obj.signal(i,1).path,'subplot', obj.signal(i,1).channelPair);
                hold on
                
                % Plot the markings
                for j = 1:numChannel
                    plotMarkings(overallP(j,1), obj.signal(i,1).time/obj.signal(i,1).samplingFreq, signPlot*dataValuesPeakDetection(:,j), obj.signalClassification(i,1).burstDetection.spikeLocs(:,j), obj.signalClassification(i,1).burstDetection.burstEndLocs(:,j), obj.signalClassification(i,1).burstDetection.threshold(j,1), obj.parameters)
                end
            end
        end
        
        function plotDetectedBursts(obj)
            f = gcf;
            axesAll = flipud(findobj(f,'Type','Axes'));
            
            fNew = figure;
            numAxes = numel(axesAll);
            numAxesNew = numAxes + 1;
            p(numAxesNew,1) = subplot(numAxesNew,1,numAxesNew);
            hold on

            if obj.parameters.showDetectedBurstsChannel == 0
                showDetectedBurstsChannel = 1:numAxes;
            else
                showDetectedBurstsChannel = obj.parameters.showDetectedBurstsChannel;
            end
            
            for i = 1:numAxes
                p(i,1) = subplot(numAxesNew,1,i,copyobj(axesAll(i,1),fNew));
                if ismember(i, showDetectedBurstsChannel)
                    notNanLocsTemp = ~isnan(obj.signalClassification.burstDetection.spikeLocs(:,i));
                    if ~isempty(notNanLocsTemp)
                        startLocsTemp = obj.signalClassification.burstDetection.spikeLocs(notNanLocsTemp,i);
                        endLocsTemp = obj.signalClassification.burstDetection.burstEndLocs(notNanLocsTemp,i);
                        xDataTemp = axesAll(i,1).Children(end).XData;
                        yDataTemp = axesAll(i,1).Children(end).YData;
                        
                        subplot(numAxesNew,1,numAxesNew)
                        for j = 1:numel(startLocsTemp)
                            locsTemp = startLocsTemp(j):endLocsTemp(j);
                            l(i,1) = plot(xDataTemp(locsTemp), yDataTemp(locsTemp),...
                                'Color',getColorArrayMatlab(i));
                        end
                    else
                        popMsg('No detected bursts are found...');
                    end
                end
            end
            linkaxes(p,'x')

            xlabel(p(numAxesNew), p(end-1).XLabel.String,...
                'FontSize',p(end-1).XLabel.FontSize,...
                'FontWeight',p(end-1).XLabel.FontWeight)
            ylabel(p(numAxesNew), p(end-1).YLabel.String,...
                'FontSize',p(end-1).YLabel.FontSize,...
                'FontWeight',p(end-1).YLabel.FontWeight)
            title(p(numAxesNew), 'Detected Bursts',...
                'FontSize',p(end-1).Title.FontSize,...
                'FontWeight',p(end-1).Title.FontWeight)
            set(p(numAxesNew), 'FontSize', p(end-1).FontSize,...
                    'LineWidth', p(end-1).LineWidth,...
                    'FontWeight', p(end-1).FontWeight);
                
            ylim(p(numAxesNew), getMiddleZeroYLimit(ylim(p(numAxesNew))));
            
            plot(p(numAxesNew), xlim,zeros(1,2),'k-');  % plot zero line

            legend(l,compose('data %d',1:numAxesNew));
            
            p(end-1).XLabel.String = '';
            close(f)
            
        end
        
        function plotOverlappingSignal(obj)
            for i = 1:length(obj.signalClassification)
                if isequal(obj.parameters.overlappedWindow, 'dataFiltered') || isequal(obj.parameters.overlappedWindow, 'dataTKEO')
                    obj.parameters.overlappedWindow = [{obj.parameters.overlappedWindow};{'values'}]; % reconstruct filtered vales, because the values lies in the field 'values' in the structure 'dataFiltered'
                end
                
                [dataValues, dataName] = loadMultiLayerStruct(obj.signal(i,1),obj.parameters.overlappedWindow); % get the values and the name of the selected window
                
                maxBurstLength = max(obj.signalClassification(i,1).burstDetection.burstEndLocs - obj.signalClassification(i,1).burstDetection.spikeLocs,[],1);
                
                obj.windowsValues(i,1) = getPointsWithinRange(...
                    obj.signal(i,1).time/obj.signal(i,1).samplingFreq,...
                    dataValues,...
                    obj.signalClassification(i,1).burstDetection.spikeLocs,...
                    obj.signalClassification(i,1).burstDetection.spikeLocs + repmat(maxBurstLength*obj.parameters.overlapWindowLengthMult,size(obj.signalClassification(i,1).burstDetection.spikeLocs,1),1),...
                    obj.parameters.windowSize, obj.signal(i,1).samplingFreq, obj.parameters.channelExtractStartingLocs);
                
                % Get all windows in same plots
                %         windowsValues(i,1).xAxisValues = reshape(windowsValues(i,1).xAxisValues,[],2*size(windowsValues(i,1).xAxisValues,2));
                %         windowsValues(i,1).burst = reshape(windowsValues(i,1).burst,[],2*size(windowsValues(i,1).burst,2));
                
                % Plot overlapping windows
                overlapP = plotFig(obj.windowsValues(i,1).xAxisValues,obj.PP.overlappingYMult*obj.windowsValues(i,1).burst,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],['Windows Following Artefacts ( ', dataName, ' )'],'Time (s)',['Amplitude (',obj.PP.overlappingYUnit,')'],...
                    obj.parameters.saveOverlap,... % save
                    obj.parameters.showOverlap,... % show
                    obj.signal(i,1).path,'overlap', obj.signal(i,1).channelPair, 'linePlot', obj.PP.overlappingYLimit);
                
                % plot averaging overlapping windows
                plotFig(obj.windowsValues(i,1).xAxisValues,obj.PP.averageYMult*nanmean(obj.windowsValues(i,1).burst,2),[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],['Average Windows Following Artefacts ( ', dataName, ' )'],'Time(s)',['Amplitude (',obj.PP.averageYUnit,')'],...
                    obj.parameters.saveOverlap,... % save
                    obj.parameters.showOverlap,... % show
                    obj.signal(i,1).path,'overlap', obj.signal(i,1).channelPair,'linePlot',obj.PP.averageYLimit);
            end
        end
        
        function plotOverallSignal(obj)
            for i = 1:length(obj.signalClassification)
                [dataValues, dataName] = loadMultiLayerStruct(obj.signal(i,1),obj.parameters.overlappedWindow); % get the values and the name of the selected window
                
                [dataTemp, channelTemp] = obj.bindSyncNCounter(obj.PP.overallYMult*dataValues, obj.parameters, obj.signal(i,1));
                overallP = plotFig(obj.signal(i,1).time/obj.signal(i,1).samplingFreq,dataTemp,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],['Overall obj.signal with Spikes Indicated (', dataName, ')'],'Time(s)',['Amplitude (',obj.PP.overallYUnit,')'],...
                    0,... % save
                    1,... % show
                    obj.signal(i,1).path,'subplot', channelTemp,'linePlot',obj.PP.overallYLimit);
                hold on
                
                % Plot the markings
                for j = 1:numChannel
                    plotMarkings(overallP(j,1), obj.signal(i,1).time/obj.signal(i,1).samplingFreq, dataValues(:,j), obj.signalClassification(i,1).burstDetection.spikeLocs(:,j), obj.signalClassification(i,1).burstDetection.burstEndLocs(:,j), nan)
                end
                
                % Save
                if obj.parameters.saveOverlap
                    savePlot(obj.signal(i,1).path,['Overall obj.signal with Spikes Indicated (', dataName, ')'],[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}],[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}])
                end
                if ~obj.parameters.showOverlap
                    close gcf
                    delete overallP overlapP
                end
            end
        end
        
        function plotComparisonSignal(obj)
            numSubplot = 2 + obj.parameters.showSyncPulse + obj.parameters.showCounter;
            for i = 1:length(obj.signal)
                numPlot = size(obj.signal(i,1).dataRaw, 2);
                for j = 1:numPlot
                    if obj.parameters.channelAveragingFlag
                        usedChannels = ['Average of ',checkMatNAddStr(obj.parameters.channelAveraging{j,1}, ',', 1)];
                    else
                        usedChannels = num2str(obj.parameters.channel(1,j));
                    end
                    
                    figure
                    hold on;
                    set(gcf, 'Position', get(0,'Screensize')-[0 0 0 80],'PaperPositionMode', 'auto');
                    
                    p(j,1) = subplot(numSubplot,1,1);
                    plot(obj.signal(i,1).time/obj.signal(i,1).samplingFreq, obj.signal(i,1).dataRaw(:,j));
                    ylabel('Amplitude (V)');
                    title([objtitleRaw, obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}, ' Channel ',usedChannels])
                    
                    p(j,2) = subplot(numSubplot,1,2);
                    plot(obj.signal(i,1).time/obj.signal(i,1).samplingFreq, obj.signal(i,1).dataFiltered.values(:,j));
                    ylabel('Amplitude (V)');
                    xlabel('Time (s)')
                    title([objtitleFiltered, obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}])
                    
                    iCurrentSubplot = 3;
                    if obj.parameters.showSyncPulse
                        p(j,iCurrentSubplot) = subplot(numSubplot,1,iCurrentSubplot);
                        plot(obj.signal(i,1).time/obj.signal(i,1).samplingFreq, obj.signal(i,1).dataAll(:,11));
                        ylabel('Amplitude');
                        xlabel('Time (s)')
                        title(['Sync pulse ', obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}])
                        iCurrentSubplot = iCurrentSubplot + 1;
                    end
                    if obj.parameters.showCounter
                        p(j,iCurrentSubplot) = subplot(numSubplot,1,iCurrentSubplot);
                        plot(obj.signal(i,1).time/obj.signal(i,1).samplingFreq, obj.signal(i,1).dataAll(:,12));
                        ylabel('Amplitude');
                        xlabel('Time (s)')
                        title(['Counter ', obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}])
                    end
                    
                    linkaxes(p, 'x');
                    
                    % Save
                    if obj.parameters.saveCompare
                        savePlot(obj.signal(i,1).path,'Comparison raw and filtered data',['Comparison raw and filtered data ', obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}, ' Channel ',num2str(j)],[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}, ' Channel ',num2str(j)])
                    end
                    if ~obj.parameters.showCompare
                        close gcf
                    end
                    
                end
            end
        end
        
        function plotRasterPlot(obj)
            for i = 1:length(obj.signal)
                titleFig = ['Raster plot ', obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}];
                obj.plotRaster(obj.rasterLocs/obj.signal.samplingFreq, obj.signalClassification(i,1).burstDetection.spikeLocs/obj.signal.samplingFreq)
                title([titleFig, ' (Threshold: ', num2str(obj.parameters.threshold), ')'])
                
                if obj.parameters.saveRaster
                    savePlot(obj.signal(i,1).path,'Raster plot', titleFig ,[obj.signal(i,1).fileName,obj.partialDataStartingTime{i,1},obj.partialDataEndTime{i,1}])
                end
                if ~obj.parameters.showRaster
                    close gcf
                end
            end
        end
        
        function plotRaster(~,rasterLocs, spikeLocs)
            [numRowSpikes, numCol] = size(spikeLocs);
            numRowRaster = size(rasterLocs, 1);
            
            % get the y axis matrix for plotting
            ySpikes = repmat(1:numCol, numRowSpikes, 1);
            yRaster = repmat(1:numCol, numRowRaster, 1);
            yRaster = yRaster(:)';
            yRaster = [yRaster-0.05; yRaster+0.05];
            
            % plots
            f = plotFig(spikeLocs, ySpikes, '', 'Raster plot', 'Time (s)', 'Channel', 0, 1, '', 'overlap', 0, 'scatterPlot', [0, numCol+1]);
            hold on
            scatterP = findobj(f, 'Type', 'scatter');
            for i = 1:length(scatterP)
                scatterP(i,1).SizeData = 100;
            end
            lRaster = plot(repmat(rasterLocs(:)',2,1), yRaster, 'k');
            f.Children = circshift(f.Children,2);
            % lRaster = plot(rasterLocs, yRaster, 'kx', 'MarkerSize', 6);
            legend(lRaster, 'Stimulation')
        end
        
        function [dataNew, channelNew] = bindSyncNCounter(~,data, parameters, signal)
            dataNew = data;
            channelNew = signal.channel;
            if parameters.showSyncPulse
                dataNew = [dataNew, signal.dataAll(:,11)];
                if size(channelNew,1) == 1
                    channelNew = [channelNew, 100];
                else
                    channelNew = [channelNew, repmat(100,size(channelNew,2))];
                end
            end
            if parameters.showCounter
                dataNew = [dataNew, signal.dataAll(:,12)];
                if size(channelNew,1) == 1
                    channelNew = [channelNew, 200];
                else
                    channelNew = [channelNew, repmat(200,size(channelNew,2))];
                end
            end
        end
        
        function output = getAxisMultiplier(~,unit)
            if strfind(unit,'u')
                output = 1e6;
            elseif strfind(unit,'m')
                output = 1e3;
            else
                output = 1;
            end
        end        
    end
end

