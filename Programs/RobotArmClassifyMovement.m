function [] = RobotArmClassifyMovement()
%stopCode open a window for stopping scanning test file
%   function [] = stopCode()
clear
close all

%% Initial Port and get ready to send command
% s = serial('COM13');
% set(s,'BaudRate',9600);
% fopen(s);

pause(3.5)

Fs = 30000; % sampling frequency
res = 0.000000195; %uV

%% Open file
% [files, path, iter] = selectFiles;
path = 'C:\DrAmit\IntanData\TestingData\';
allFiles = dir(path);
numFiles = length(allFiles);
numUpdatedFiles = numFiles;

%% Create Uicontrol Button
f = figure('Name','Scanning Testing Data',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Units','normalized',...
    'Position',[0.33, 0.42, 0.33, 0.1]);

s = uicontrol('Style','Toggle',...
    'String','Start!',...
    'Units','Normalized',...
    'Position',[.37, .25, .2, .35],...
    'CallBack',@stopScanning);

    function [] = stopScanning(varargin)
        set(s,'String','Stop!')
        drawnow
        while 1
            allFiles = dir(path);
            numFiles = length(allFiles);
            
            drawnow
            
            if numUpdatedFiles ~= numFiles
                [~,idx] = sort([allFiles.datenum],'descend');
                files = allFiles(idx(3)).name;
                
                %% Reconstruct
                [data{1,1}, time{1,1}] = reconstructData(files, path, res);
                
                %% Detect Spike
                spikeTiming = detectSpikes(data);
                
                %% Get Feature
                windowSize = 0.4; % second
                windowsClassification = classificationWindowSelection(data, spikeTiming.spikeLocs, windowSize, Fs);
                
                features.classOne = featureExtraction(windowsClassification.windowClassOne);
                
                %% Read text file
                textContent = readText;
                classifierParameter.const = textContent(1);
                classifierParameter.linear = textContent(2);
                classifierParameter.windowSize = textContent(3);
                classifierParameter.threshold = textContent(4);
                classifierParameter.channel = textContent(5);
                
                
                %% Move Robot Arm
%                 command = predictMovement(features.classOne, classifierParameter);
                
%                 for j = 1:length(command)
%                     pause(1.75);
%                     fprintf(s,command(j));
%                     pause(1.75);
%                 end
%                 
%                 fclose(s);
                
                display('Finished.')
                
                msg1 = popMsg('', 'Finished.');
                pause(1)
                delete(msg1)
                
                numUpdatedFiles = numFiles;
                
            end
            
            if ~get(s,'value')
                set(s,'String','Start!')
                break
            end
            
        end
    end

end

