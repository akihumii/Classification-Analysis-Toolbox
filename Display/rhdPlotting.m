function [output,settings] = rhdPlotting(varargin)
%% Plot EMG Wired Rat Data
% Load .rhd files and plot the raw and filter signals & frequency spectrum
% Input:    1.  Channel(s) that need to process. Key in 0 to finish. 
%               Note that the first channel is always 1 in Matlab.
%           2.  Select .rhd file(s) that need to process.
% 
% Output:   1.  Raw Signal
%           2.  Filtered Signal
%           3.  Raw Frequency Spectrum
%           4.  Filtered Frequency Spectrum

clear
close all
clc
%% default parameters
Fs = 20000; % sampling rate
Fc1 = 3; % HPF cutoff freq
Fc2 = 3000; % LPF cutoff freq 
fqNotch = 50; % notch filter freq
for count = 1:12
    stopf(count) = 100+50*(count-1);
    s1(count) = stopf(count)-2;
    s2(count) = stopf(count)+2;
end

%% Input Channels number
ch = str2double(input('Channel : ','s'));
while ch(end) ~= 0
    ch = [ch, str2double(input('','s'))];
end
ch(end) = [];

% ch = [14,16];

disp('Processing...')

%% input parameters
if nargin == 1
    ch = varargin{1};
elseif nargin == 2
    ch = varargin{1};
    Fc1 = varargin{2}; %HPF cutoff freq
elseif nargin == 3
    ch = varargin{1};
    Fc1 = varargin{2}; %HPF cutoff freq
    Fc2 = varargin{3}; %LPF cutoff freq
end

chN = length(ch);
settings.Fs = Fs;
settings.Fc1 = Fc1;
settings.Fc2 = Fc2;
settings.ch = ch;
settings.chN = chN;
settings

%% build filter
[bHigh, aHigh] = butter(4,Fc1/(Fs/2),'high');
[bLow, aLow] = butter(4,Fc2/(Fs/2),'low');
for stopno = 1:length(stopf)
    [bStop{stopno},aStop{stopno}] = butter(3,[s1(stopno)/(Fs/2) s2(stopno)/(Fs/2)],'stop');
end
% [bNotch, aNotch] = iirnotch(fqNotch/(Fs/2), fqNotch/(35*(Fs/2)));

% Individual Filter Frequency
% for stopno = 1:length(f)
%     [bStop2{stopno},aStop2{stopno}] = butter(1,[f1(stopno)/(Fs/2) f2(stopno)/(Fs/2)],'stop');
% end

%% load and combine files
[files, path] = uigetfile('*.rhd','select EMG Signal rhd file','MultiSelect','on');

if iscell(files)
    iter = length(files);
else
    iter = 1;
    files = cellstr(files);
end

for i = 1:chN
    data{i,:} = cell(1,iter);
end
time = cell(1,iter);


%% Main Dish
for i = 1:iter
    [amplifier_data, t_amplifier] = readIntan([path files{i}]);
    for j = 1:chN
        data{j,i} = amplifier_data(ch(j),:);
        time{j,i} = t_amplifier;
        
    end
    
    
    %% filter data
    for j = 1:chN
        dataHPF{j,i} = filtfilt(bHigh,aHigh,data{j,i});
        dataBSF{j,i} = filtfilt(bLow,aLow,dataHPF{j,i});
%         dataBSF{j,i} = filter(bStop{1},aStop{1},dataBPF{j,i});
%         if length(stopf) > 1
%             for stopno = 2:length(stopf)
%                 dataBSF{j,i} = filter(bStop{stopno},aStop{stopno},dataBSF{j,i});
%             end
%         end
%         dataBSF{j,i} = filter(bNotch, aNotch,dataBPF{j,i});
    end
    
    %% Frequency spectrum
    titlename{i} = files{i}(1:(end-4));
    NFFT = 2^15;
    for alpha = 1:chN
        fftdata{alpha,i} = fftshift(fft(dataBSF{alpha,i},NFFT));
    end
    fVals = Fs*(-NFFT/2:NFFT/2-1)/NFFT;
    
    sp = length(fVals)/2-1200;
    ep = length(fVals)/2+1200;
    
    % Plotting
    figure
    hold on;
    set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',8,...
        'PaperPositionMode', 'auto');
    
    
    for alpha = 1:chN
        p(alpha,2) = subplot(chN,1,alpha);
        plot(fVals(sp:ep),abs(fftdata{alpha,i}(sp:ep)));
        title(['Filtered Frequency Spectrum of ' titlename{i} ' ch ' num2str(ch(alpha))], 'fontsize', 8);
        ylabel('DFT Values');
        axis tight;
    end
    xlabel('Frequency(Hz)');
    linkaxes(p(:,2),'x');
    
    
    %% Raw frequency spectrum
    NFFT = 2^15;
    for alpha = 1:chN
        fftdata{alpha,i} = fftshift(fft(data{alpha,i},NFFT));
    end
    fVals = Fs*(-NFFT/2:NFFT/2-1)/NFFT;
    
    sp = length(fVals)/2-1200;
    ep = length(fVals)/2+1200;
    
    % Plotting
    figure
    set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',8,...
        'PaperPositionMode', 'auto');
    for alpha = 1:chN
        p(alpha,2) = subplot(chN,1,alpha);
        plot(fVals(sp:ep),abs(fftdata{alpha,i}(sp:ep)));
        title(['Raw Frequency Spectrum of ' titlename{i} ' ch ' num2str(ch(alpha))], 'fontsize', 8);
        ylabel('DFT Values');
        axis tight;
    end
    xlabel('Frequency(Hz)');
    linkaxes(p(:,2),'x');
    
    
    %% plot raw & filtered signals
    % Raw data
    figure
    set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',8,...
        'PaperPositionMode', 'auto');
    for alpha = 1:chN
        p(alpha,1) = subplot(chN,1,alpha);
        plot(time{alpha,i},data{alpha,i})
        title([titlename{i} ' Channel ' num2str(ch(alpha)) ' Raw Signal'], 'fontsize', 8)
        ylabel('Amplitude (\muV)')
        axis('tight')
        hold on
    end
    xlabel('Time (s)');
    linkaxes(p(:,1),'x');
    
    % Filtered data
    figure
    set(gcf, 'Position', get(0,'Screensize'),'DefaultAxesFontSize',8,...
        'PaperPositionMode', 'auto');
    for alpha = 1:chN
        p(alpha,2) = subplot(chN,1,alpha);
        plot(time{alpha,i},dataBSF{alpha,i})
        title([titlename{i} 'Channel ' num2str(ch(alpha)) ' Filtered Signal (BP' num2str(Fc1) '-' num2str(Fc2) ')'], 'fontsize', 8)
        ylabel('Amplitude (\muV)')
        axis('tight');
        hold on
    end
    xlabel('Time (s)')
    linkaxes(p(:,2),'x');

    %%
    close all

end
output.raw = data;
output.filtered = dataBSF;
output.time = time;
output.titlename = titlename;
output.path = path;

end
