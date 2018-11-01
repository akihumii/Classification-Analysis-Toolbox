function varargout = deleteBurst(type, p, time, samplingFreq, varargin)
%deleteBurst Delete or choose bursts by inputting their indexes
%
% input: type: 1 for delete, 2 for choose
%
% intput & output: varargout & varargin = onsetValues, onsetLocs,
% offsetValues, offsetLocs
% output: varargout{1,5} = selectedBursts
%
%   varargout = deleteBurst(type, p, time, samplingFreq, varargin)

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
        yLimit = get(gca,'ylim');
        
        onsetLocsTemp = onsetLocsRaw(~isnan(onsetLocsRaw));
        burstNumTemp = size(onsetLocsTemp,1);
        
        hold on
        for i = 1:burstNumTemp
            pStart = plot(time(onsetLocsTemp(i,1))/samplingFreq, onsetValuesTemp(i,1), 'ro'); % onset points
            pEnd = plot(time(offsetLocsTemp(i,1))/samplingFreq, offsetValuesTemp(i,1), 'rx'); % offset points
            legend([pStart,pEnd],'starting points','end points');
            t = text(time(onsetLocsTemp(i,1))/samplingFreq, yLimit(1)/1e4, num2str(i));
            t.FontSize = 13;
        end
        hold off
        
        %% Input bursts index
        disp('Input bursts index:')
        selectedBursts{n,1} = zeros(0,1);
        selectedBursts{n,1} = [selectedBursts{n,1};input('')];
        while selectedBursts{n,1}(end) ~= 0
            selectedBursts{n,1} = [selectedBursts{n,1};input('')];
        end
        selectedBursts{n,1}(end) = [];
        
    end
    
    %% Delete unwatned bursts
    for i = 5:nargin
        for n = 1:numAxes
            outputTemp{n,1} = varargin{1,i-4}(:,n);
            if type == 1 % to delete selected indexes
                outputTemp{n,1}(selectedBursts{n,1}) = [];
                outputTemp{n,1} = squeezeNan(outputTemp{n,1},2);
            else % to pick selected indexes
                outputTemp{n,1} = outputTemp{n,1}(selectedBursts{n,1});
                outputTemp{n,1} = squeezeNan(outputTemp{n,1},2);
            end
        end
        varargout{1,i-4} = cell2nanMat(outputTemp);
        clear outputTemp
    end
    close
    varargout{1,5} = selectedBursts;
end
end

