function varargout = deleteBurst(type, way, p, time, samplingFreq, varargin)
%deleteBurst Delete or choose bursts by inputting their indexes
%
% input: type:  1 for delete, 2 for choose
%        way:   'key' to key in zeros, end the process by entering 0;
%               'drag' to drag the area that containst the burst, end the process by hitting 'Enter'
%
% intput & output: varargout & varargin = onsetValues, onsetLocs,
% offsetValues, offsetLocs, markBurstInAllChannels
% output: varargout{1,5} = selectedBursts
%
%   varargout = deleteBurst(type, way, p, time, samplingFreq, varargin)

if ~any(type==1 | type==2)
    warning('Invalid type for burst trimming...');
else
    numAxes = size(varargin{1,1},2);
    for n = 1:numAxes
        onsetValuesTemp = varargin{1,1}(:,n);
        onsetLocsRaw = varargin{1,2}(:,n);
        offsetValuesTemp = varargin{1,3}(:,n);
        offsetLocsTemp = varargin{1,4}(:,n);
        
        %% plot the texts on axes
        axes(p(n))
        addToolbarExplorationButtons(gcf);
        
        yLimit = get(gca,'ylim');
        
        onsetLocsTemp = onsetLocsRaw(~isnan(onsetLocsRaw));
        burstNumTemp = size(onsetLocsTemp,1);
        
        hold on
        for i = 1:burstNumTemp
            pStart = plot(time(onsetLocsTemp(i,1))/samplingFreq, onsetValuesTemp(i,1), 'ro'); % onset points
            pEnd = plot(time(offsetLocsTemp(i,1))/samplingFreq, offsetValuesTemp(i,1), 'rx'); % offset points
            if ~varargin{1,5}
                t = text(time(onsetLocsTemp(i,1))/samplingFreq, yLimit(1)/1e4, num2str(i));
            elseif n == numAxes
                t = text(time(onsetLocsTemp(i,1))/samplingFreq, yLimit(1)/1e4, num2str(i));
            end
            t.FontSize = 13;
        end
        
        if ~varargin{1,5}
            selectedBursts = selectBursts(onsetLocsTemp, offsetLocsTemp, samplingFreq, burstNumTemp, pStart, pEnd, n, way, p, time);
        end
    end
    
    %% If parameters 'markBurstInAllChannels' is true
    if varargin{1,5}
        selectedBursts = selectBursts(onsetLocsTemp, offsetLocsTemp, samplingFreq, burstNumTemp, pStart, pEnd, n, way, p, time);
        selectedBurstsAll = horzcat(selectedBursts{:});
        for i = 1:numAxes
            selectedBursts{i,1} = selectedBurstsAll;
        end
    end
    
    popMsg('Finished processing current figure...');
    
    %% Delete unwatned bursts
    for i = 6:nargin-1
        for n = 1:numAxes
            outputTemp{n,1} = varargin{1,i-5}(:,n);
            if ~isempty(selectedBursts{n,1}) && all(~isnan(selectedBursts{n,1}))
                if type == 1 % to delete selected indexes
                    outputTemp{n,1}(selectedBursts{n,1}) = [];
                else % to pick selected indexes
                    outputTemp{n,1} = outputTemp{n,1}(selectedBursts{n,1});
                end
            end
            outputTemp{n,1} = squeezeNan(outputTemp{n,1},2);
        end
        varargout{1,i-5} = cell2nanMat(outputTemp);
        clear outputTemp
    end
    close
    varargout{1,5} = selectedBursts;
end

    function dragData(src,event)
        
    end
end

function selectedBursts = selectBursts(onsetLocsTemp, offsetLocsTemp, samplingFreq, burstNumTemp, pStart, pEnd, n, way, p, time)
if burstNumTemp > 0
    legend([pStart,pEnd],'starting points','end points');
    
    hold off
    
    %% Input bursts index
    selectedBursts{n,1} = zeros(0,1);
    
    disp(' ')
    disp('Start selecting bursts:')
    switch way
        case 'key'
            disp('Input bursts index:')
            selectedBursts{n,1} = [selectedBursts{n,1};input('')];
            while selectedBursts{n,1}(end) ~= 0
                selectedBursts{n,1} = [selectedBursts{n,1};input('')];
            end
            selectedBursts{n,1}(end) = [];
            
        case 'drag'
            while true
                selectedBurstsTemp = getrbboxData(p(n),...
                    time(onsetLocsTemp)/samplingFreq,time(offsetLocsTemp(~isnan(offsetLocsTemp)))/samplingFreq);
                if selectedBurstsTemp == -1
                    break
                elseif ~isempty(selectedBurstsTemp)
                    disp(num2str(selectedBurstsTemp))
                    selectedBursts{n,1} = [selectedBursts{n,1};selectedBurstsTemp];
                end
            end
        otherwise
    end
else
    selectedBursts{n,1} = nan;
end
end

