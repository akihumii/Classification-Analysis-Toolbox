function varargout = onlineClassificationGUI(varargin)
% ONLINECLASSIFICATIONGUI MATLAB code for onlineClassificationGUI.fig
%      ONLINECLASSIFICATIONGUI, by itself, creates a new ONLINECLASSIFICATIONGUI or raises the existing
%      singleton*.
%
%      H = ONLINECLASSIFICATIONGUI returns the handle to a new ONLINECLASSIFICATIONGUI or the handle to
%      the existing singleton*.
%
%      ONLINECLASSIFICATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLINECLASSIFICATIONGUI.M with the given input arguments.
%
%      ONLINECLASSIFICATIONGUI('Property','Value',...) creates a new ONLINECLASSIFICATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before onlineClassificationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to onlineClassificationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help onlineClassificationGUI

% Last Modified by GUIDE v2.5 26-Feb-2019 15:47:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @onlineClassificationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @onlineClassificationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before onlineClassificationGUI is made visible.
function onlineClassificationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to onlineClassificationGUI (see VARARGIN)

% Choose default command line output for onlineClassificationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes onlineClassificationGUI wait for user response (see UIRESUME)
% uiwait(handles.bgOnlineClassificationGUI);


% --- Outputs from this function are returned to the command line.
function varargout = onlineClassificationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{1,2} = handles;

% setup the flags
handles.UserData = setupUserData();

% change enablity of inputThresh
if strcmp('Threshold', handles.panelClassificationMethod.SelectedObject.String)
    handles.tableThresh.Enable = 'on';
else
    handles.tableThresh.Enable = 'off';
end

handles.tableThresh.Data = cell(1,4);
handles.inputThreshMult.Data = cell(1,4);

% Update handles structure
guidata(hObject, handles);

warning('off','all');


% --- Executes during object creation, after setting all properties.
function panelOption_CreateFcn(hObject, eventdata, handles)


function buttonStartStop_Callback(hObject, eventdata, handles)
switch handles.UserData.stopFlag
    case 0
        resetAll(hObject, handles);
    case 1
        if handles.UserData.startAllFlag
            disp('Program started...')
            handles.dispPrediciton.String = num2str([0,0,0,0]);
            handles.dispStatus.String = 'Program started...';
            handles.buttonStartStop.String = 'Stop';
            handles.buttonStartStop.ForegroundColor = 'r';
            handles.UserData.openPortFlag = 0;
            handles.UserData.stopFlag = 0;
            
            guidata(hObject, handles);
            
            
            if ~handles.UserData.stopFlag && ~handles.UserData.openPortFlag
                handles = setupClassifier(handles);
                guidata(hObject, handles);
            end
            
            predictClassAll = zeros(1, handles.UserData.parameters.numChannel);
            
            while ~handles.UserData.stopFlag && handles.UserData.openPortFlag
                predictClassAll = runProgram(handles, predictClassAll);  % run classification
                handles = guidata(hObject);    
            end
            handles.UserData.openPortFlag = 0;
                
        else
            popMsg('Select a trained .mat file first...');
        end
    otherwise
        disp('How did you get in here !?')
end



function buttonReselect_Callback(hObject, eventdata, handles)
disp(' ')
disp('Reselect training files...')
try
    [files,path] = selectFiles('Select trained parameters .mat file...');
    classifierParameters = load(fullfile(path,files{1,1}));
    classifierParameters = classifierParameters.varargin{1,1};
    
    resetAll(hObject, handles);
    
    handles.UserData.startAllFlag = 1;
    
    handles.inputThreshMult.Data = checkSizeNTranspose(classifierParameters{1,1}.threshMultStr, 1);
    
    handles.UserData.classifierParameters = classifierParameters;
    
    popMsg('Trained file selected...');
catch
    popMsg('Reselct failed...');
end
guidata(hObject, handles);


function buttonTrain_Callback(hObject, eventdata, handles)
disp(' ')
try
    onlineClassifierTraining();
    resetAll(hObject, handles);
    popMsg('Training done...');
catch
    resetAll(hObject, handles);
    popMsg('Training failed...');
end
guidata(hObject, handles);


function buttonSaveFeatures_Callback(hObject, eventdata, handles)
disp(' ')
try
    [threshMultStr, signal, signalClassificationInfo, saveFileName] = onlineClassifierDetectBursts();
    saveBurstsInfo(signal, signalClassificationInfo, saveFileName);
    handles.inputThreshMult.Data = checkSizeNTranspose(threshMultStr, 1);
catch
    handles.UserData.threshMultStr = '';
end
guidata(hObject, handles);


% --- Executes when user attempts to close bgOnlineClassificationGUI.
function bgOnlineClassificationGUI_CloseRequestFcn(hObject, eventdata, handles)
handles.UserData.stopAll = 1;
guidata(hObject, handles);
% Hint: delete(hObject) closes the figure
delete(hObject);


function panelClassificationMethod_SelectionChangedFcn(hObject, eventdata, handles)
if strcmp('Threshold', handles.panelClassificationMethod.SelectedObject.String)
    handles.tableThresh.Enable = 'on';
else
    handles.tableThresh.Enable = 'off';
end
resetAll(hObject, handles)


function panelClassificationMethod_CreateFcn(hObject, eventdata, handles)


function output = setupUserData(handles)
output = struct(...
    'startAllFlag', 0,...
    'stopFlag', 1,...
    'openPortFlag', 0,...
    'stopAll', 0);

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
    % IMPORTANT! download pscp in order to use this command
    try  % for Windows
        systemCmd = sprintf('pscp -pw raspberry -scp %s pi@192.168.4.3:~/classificationTmp/', fullfile(filepath, savedClassifier(i,1).name));
        system(systemCmd)
    catch
        try  % for Linux
            systemCmd = sprintf('sshpass -p raspberry scp %s pi@192.168.4.3:~/classificationTmp/', fullfile(filepath, savedClassifier(i,1).name));
            system(systemCmd)
        catch
            warning('failed to transfer file...')
        end
    end
end


function resetAll(hObject, handles)
disp('Program stopped...')

handles.dispPrediciton.String = num2str([0,0,0,0]);
handles.dispStatus.String = 'Program stopped...';
handles.buttonStartStop.String = 'Start';
handles.buttonStartStop.ForegroundColor = [0,190/256,0];
handles.UserData.stopFlag = 1;
handles.UserData.openPortFlag = 0;

guidata(hObject, handles);


function predictClassAll = runProgram(handles, predictClassAll)
try
    for i = 1:handles.UserData.parameters.numChannel
        readSample(handles.UserData.classInfo{i,1});
        %         plot(h(i,1),handles.UserData.classInfo{i,1}.dataFiltered)
        %         pause(0.0001)
        %             detectBurst(handles.UserData.classInfo{i,1});
        classifyBurst(handles.UserData.classInfo{i,1});
        
        if predictClassAll(1,i) ~= handles.UserData.classInfo{i,1}.predictClass % update if state changed
            predictClassAll(1,i) = handles.UserData.classInfo{i,1}.predictClass;
            if all(predictClassAll(1:2))
                predictClassAll(2) = 0;
            end
            if all(predictClassAll(3:4))
                predictClassAll(4) = 0;
            end
            handles.dispPrediction.String = num2str(predictClassAll);
            replyPredictionDec = bi2de(predictClassAll,'left-msb');
            fwrite(handles.UserData.tB,[handles.UserData.parameters.channelEnable,replyPredictionDec]); % to enable the channel
            drawnow
        end
        
        %             disp(['Class ',num2str(i),' prediction: ',num2str(handles.UserData.classInfo{i,1}.predictClass)]);
        %             elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
    end
    
catch
    handles.UserData.startAllFlag = 0;
    handles.dispPrediction.String = num2str([0,0,0,0]);
    handles.dispStatus.String = 'Program stopped...';
    handles.buttonStartStop.String = 'Start';
    handles.buttonStartStop.ForegroundColor = [0,190/256,0];
    handles.UserData.stopFlag = 1;
    handles.UserData.openPortFlag = 0;
    handles.UserData.startAllFlag = 0;
    popMsg('Wrong selection, please start over...');
    drawnow
end
drawnow
    

function handles = setupClassifier(handles)
%% Parameters
parameters = struct(...
    'overlapWindowSize',50,... % ms
    'ports',[1343,1344,1345,1346],...
    'replyPort',1300,...
    'channelEnable',251,...
    'numChannel',length(handles.UserData.classifierParameters));

for i = 1:parameters.numChannel
    classInfo{i,1} = classOnlineClassification(); % Initiatialize the object

    switch handles.panelClassificationMethod.SelectedObject.String
        case 'Features'
            setBasicParameters(classInfo{i,1},handles.UserData.classifierParameters{i,1},parameters,handles.panelClassificationMethod.SelectedObject.String);
        case 'SimpleThresholding'
            setBasicParameters(classInfo{i,1},handles.UserData.classifierParameters{i,1},parameters,handles.panelClassificationMethod.SelectedObject,str2double(handles.tableThresh.Data{1,i}));
    end
            
    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client','Timeout',1);

    % Streaming data
    tcpip(classInfo{i,1}); % open channel port
    openPort(classInfo{i,1});
end

% open reply port
try
    tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client','Timeout',1);
    disp(['Opened port ',num2str(parameters.channelEnable),' as reply port...'])
catch
    disp(['Reply port ',num2str(parameters.channelEnable),' is not open yet...'])
end

fopen(tB);

%%  Run the online classification
%     clearvars -except parameters classInfo tB

% elapsedTime = cell(parameters.numChannel,1);

handles.UserData.openPortFlag = 1;
handles.UserData.classInfo = classInfo;
handles.UserData.parameters = parameters;
handles.UserData.tB = tB;


% --- Executes during object creation, after setting all properties.
function bgOnlineClassificationGUI_CreateFcn(hObject, eventdata, handles)


% --- Executes when entered data in editable cell(s) in tableThresh.
function tableThresh_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tableThresh (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
