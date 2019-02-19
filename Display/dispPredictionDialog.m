function dispPredictionDialog()
%DISPPREDICTIONDIALOG Summary of this function goes here
%   Detailed explanation goes here
close hidden

global startAllFlag
global stopFlag
global openPortFlag
global classifierParameters
global tNumber
global buttonStartStop
global tStatus
global tMult
global stopAll

warning('off','all');

a=[0,0,0,0];

textSize = 25;
textReselectSize = 10;
textSizePredictionClass = 50;
screenSize = get(0,'Screensize');
windowPosition = [1, screenSize(1,4)*.7, screenSize(1,3)*.25, screenSize(1,4)*.25];

p = figure('Name','SINAPSE CAT V1','NumberTitle','off','CloseRequestFcn',@closeProgram);
set(gcf, 'Position', windowPosition, 'MenuBar', 'none', 'ToolBar', 'none');


tStatus = uicontrol(gcf,'Style','text','String','Program stopped...','HorizontalAlignment','left','FontSize',textSize,'Unit','normalized','Position',[0.15,0.66,0.6,0.25]);

tNumber = uicontrol(gcf,'Style','text','String',num2str(a),'FontSize',textSizePredictionClass,'Unit','normalized','Position',[0.1,0.43,0.8,0.3]);

tMult = uicontrol(gcf,'Style','text','String',[{'threshMult'};{num2str(a')}],'FontSize',textReselectSize,'Unit','normalized','Position',[.001,.45,.16,.3]);

buttonStartStop = uicontrol(gcf,'Style','push','String','Start','FontWeight','bold','ForegroundColor',[0,190/256,0],'FontSize',textSize,'Unit','normalized','Position',[.15,0.1,0.7,0.25],'CallBack',@changeState);

buttonReselect = uicontrol(gcf,'Style','push','String','Reselect','FontWeight','bold','ForegroundColor','k','FontSize',textReselectSize,'Unit','normalized','Position',[.78,0.855,0.2,0.1],'CallBack',@reselectFile);
buttonTrain = uicontrol(gcf,'Style','push','String','Train','FontWeight','bold','ForegroundColor','k','FontSize',textReselectSize,'Unit','normalized','Position',[.78,0.755,0.2,0.1],'CallBack',@trainClassifier);
buttonSaveFeature = uicontrol(gcf,'Style','push','String','SaveFeatures','FontWeight','bold','ForegroundColor','k','FontSize',textReselectSize,'Unit','normalized','Position',[.78,0.655,0.2,0.1],'CallBack',@saveFeatures);

    function changeState(~,~)
        switch stopFlag
            case 0
                    disp('Program stopped...')
                    resetAll();
            case 1
                if startAllFlag
                    disp('Program started...')
                    tNumber.String = num2str([0,0,0,0]);
                    tStatus.String = 'Program started...';
                    buttonStartStop.String = 'Stop';
                    buttonStartStop.ForegroundColor = 'r';
                    openPortFlag = 0;
                    stopFlag = 0;
                else
                    popMsg('Select a trained .mat file first...');
                end
            otherwise
                disp('How did you get in here !?')
        end
        drawnow
    end

    function reselectFile(~,~)
        disp(' ')
        disp('Reselect training files...')
        try
            [files,path] = selectFiles('Select trained parameters .mat file...');
            classifierParameters = load(fullfile(path,files{1,1}));
            classifierParameters = classifierParameters.varargin{1,1};
                        
            resetAll();
            
            startAllFlag = 1;
            
            tMult.String = [{'threshMult'};classifierParameters{1,1}.threshMultStr];
            
            popMsg('Trained file selected...');
        catch
            popMsg('Reselct failed...');
        end
        drawnow
    end

    function trainClassifier(~,~)
        disp(' ')
        try
            onlineClassifierTraining();
            resetAll();
            popMsg('Training done...');
        catch
            resetAll();
            popMsg('Training failed...');
        end
        drawnow
    end

    function saveFeatures(~,~)
        disp(' ')
        try
            [threshMultStr, signal, signalClassificationInfo, saveFileName] = onlineClassifierDetectBursts();
            saveBurstsInfo(signal, signalClassificationInfo, saveFileName);
        catch
        end
        drawnow
    end

    function saveBurstsInfo(signal, signalClassificationInfo, saveFileName)
        featuresForClassification = [5,7];  % selected features for classification        
        numChannel = length(signalClassificationInfo);
        
        % Make a folder to store the features and corresponding classes
        filepath = fileparts(saveFileName{1,1});
        filepath = fullfile(filepath, 'classificationTmp');
        if ~exist(filepath,'file')
            mkdir(filepath);
        end
        
        for i = 1:numChannel
            timeStamps = time2string();
            [~, filename] = fileparts(saveFileName{1,1});
            fullfilenameFeature = fullfile(filepath,sprintf('featuresCh%d_%s_%s.csv', signal(i,1).channel(1,i), filename, timeStamps));
            fullfilenameClass = fullfile(filepath,sprintf('classCh%d_%s_%s.csv', signal(i,1).channel(1,i), filename, timeStamps));
            
            featureStruct = signalClassificationInfo(i,1).features;
            featureStruct = rmfield(featureStruct, 'dataAnalysed');  % to make it able to build a full table
            featureTable = struct2table(featureStruct);
            
            feature = table2array(featureTable(:,featuresForClassification));  % get the target features
            feature = feature(:,i:numChannel:end);  % get the target class
            feature = reshape(feature,[],2);  % reshape into columns of different features
            
            feature = omitNan(feature,2,'any');
            numBursts = size(feature,1);
            class = reshape(repmat([1,2], numBursts/2, 1), [], 1);
            
            % save features and classes
            csvwrite(fullfilenameFeature, feature)
            disp(['Saved ', fullfilenameFeature, '...']);
            csvwrite(fullfilenameClass, class)
            disp(['Saved ', fullfilenameClass, '...']);
        end
        
        popMsg('Features and Classes saving finished...');
        
        % train python classifier
        systemCmd = sprintf('python %s %s', fullfile('C:', 'classificationTraining.py'), filepath);
        system(systemCmd)
        
        % transfer classifier to rpi
        cwd = pwd;
        cd(filepath)
        savedClassifier = dir('*.sav');  % get all the saved classifier
        cd(cwd)
        
        for i = 1:length(savedClassifier)
            systemCmd = sprintf('pscp -pw raspberry -scp %s pi@192.168.4.3:~/classificationTmp/', fullfile(filepath, savedClassifier(i,1).name));
            system(systemCmd)
        end

    end

    function resetAll()
        tNumber.String = num2str([0,0,0,0]);
        tStatus.String = 'Program stopped...';
        buttonStartStop.String = 'Start';
        buttonStartStop.ForegroundColor = [0,190/256,0];
        stopFlag = 1;
        openPortFlag = 0;
    end

    function closeProgram(~,~)
%         pause
        close all
        stopAll = 1;
    end
end


