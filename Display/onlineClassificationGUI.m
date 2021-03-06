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

% Last Modified by GUIDE v2.5 26-Aug-2019 16:29:06

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

% setup the UserData
setupUserData(hObject, handles);
handles = guidata(hObject);

% close all serial port connection
instrreset

% change enablity of inputThresh
if strcmp('Threshold', handles.panelClassificationMethod.SelectedObject.String)
    handles.tableThresh.Enable = 'on';
else
    handles.tableThresh.Enable = 'off';
end

% handles.UserData.numChannelDisp = 4;
handles.tableThresh.Data = cell(handles.UserData.numChannelDisp,1);
handles.inputThreshMult.Data = cell(1,handles.UserData.numChannelDisp);
handles.inputArtefact.Data = cell(handles.UserData.numChannelDisp,1);
for i = 1:handles.UserData.numChannelDisp
    handles.tableThresh.Data{i,1} = Inf;
    handles.inputArtefact.Data{i,1} = nan;
end

% Filter configuration
handles.inputFilter.Data = num2cell([100;7500]);
handles.inputFilter.RowName(3:end) = [];

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
            handles.dispPrediciton.String = num2str(zeros(1,handles.UserData.numChannelDisp));
            handles.dispStatus.String = 'Program started...';
            handles.buttonStartStop.String = 'Stop';
            handles.buttonStartStop.ForegroundColor = 'r';
            handles.UserData.openPortFlag = 0;
            handles.UserData.stopFlag = 0;
            
            guidata(hObject, handles);
            
            if ~handles.UserData.openPortFlag
                handles = setupClassifier(handles);
                guidata(hObject, handles);
            end
            
            if ~handles.UserData.bionicHandConnection && ~isequal(handles.UserData.portHand(4:end), 'nan')
                try
                    handles.UserData.tH = bionicHand(handles.UserData.portHand);
                    guidata(hObject, handles)
                catch
%                     allPorts = instrfind;
%                     serialPortsLocs = ismember(get(allPorts,'Type'),'serial');
%                     allNames = get(allPorts,'Name');
%                     serialPorts = cell2mat(allNames(serialPortsLocs));
%                     helpdlgBox = helpdlg(serialPorts,'Available COMPORT:');
%                     helpdlgBox.Position(3) = 210;
                    popMsg('Invalid COMPORT!');
                    resetAll(hObject, handles);
                end
            end
            
            predictClassAll = zeros(1, handles.UserData.parameters.numChannel);
            
            pause(2) % for robot hand to work properly
            
            for i = 1:handles.UserData.parameters.numChannel
                flushinput(handles.UserData.classInfo{i,1}.t);  % flush input data
            end            
            
            while handles.UserData.openPortFlag
                predictClassAll = runProgram(hObject, handles, predictClassAll);  % run classification
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
try
    [files,path] = selectFiles('Select trained parameters .mat file...');
    
    popMsg('Reselect training files...')
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
    onlineClassifierTraining(handles);
    resetAll(hObject, handles);
    popMsg('Training done...');
catch
    resetAll(hObject, handles);
    popMsg('Training failed...');
end
guidata(hObject, handles);


function buttonSaveFeatures_Callback(hObject, eventdata, handles)
disp(' ')
% try
    [threshMultStr, signal, signalClassificationInfo, saveFileName, parameters] = onlineClassifierDetectBursts(handles);
    [fullfilenameFeature, fullfilenameClass] = saveBurstsInfo(signal, signalClassificationInfo, saveFileName, parameters.markBurstInAllChannels);
    getPythonClassifier(fullfilenameFeature, fullfilenameClass);
    handles.inputThreshMult.Data = checkSizeNTranspose(threshMultStr, 1);
    popMsg('Finished feature saving...');
% catch
%     popMsg('Error while saving features...');
%     handles.UserData.threshMultStr = '';
% end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bgOnlineClassificationGUI_CreateFcn(hObject, eventdata, handles)


% --- Executes when entered data in editable cell(s) in tableThresh.
function tableThresh_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data

try
    for i = 1:length(handles.inputArtefact.Data)
        handles.UserData.classInfo{i,1}.thresholds = handles.tableThresh.Data{i,1};
    end
catch
end

guidata(hObject, handles);

function inputWindowSize_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of inputWindowSize as text
%        str2double(get(hObject,'String')) returns contents of inputWindowSize as a double
lowerLimit = 50;
if str2num(get(hObject,'String')) < lowerLimit
    errordlg('Window size smaller than lower limit...');
    handles.inputWindowSize.String = lowerLimit;
end

try
    for i = 1:length(handles.UserData.numChannelDisp)
        handles.UserData.classInfo{i,1}.windowSize = str2num(handles.inputWindowSize.String);
    end
    popMsg(sprintf('Changed window size to %d ms...', handles.UserData.classInfo{i,1}.windowSize));
catch
    popMsg('Failed to change window size...');
end

resetAll(hObject, handles);



% --- Executes during object creation, after setting all properties.
function inputWindowSize_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function inputBlankSize_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of inputBlankSize as text
%        str2double(get(hObject,'String')) returns contents of inputBlankSize as a double
try
    for i = 1:length(handles.UserData.numChannelDisp)
        handles.UserData.classInfo{i,1}.blankSize = str2num(handles.inputBlankSize.String);
    end
    popMsg(sprintf('Changed blank size to %d ms...', handles.UserData.classInfo{i,1}.blankSize));
catch
    popMsg('Failed to input blank size...');
end

resetAll(hObject, handles);



% --- Executes during object creation, after setting all properties.
function inputBlankSize_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
resetAll(hObject, handles);


% --- Executes when entered data in editable cell(s) in inputArtefact.
function inputArtefact_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% resetAll(hObject, handles);
try
    for i = 1:length(handles.inputArtefact.Data)
        handles.UserData.classInfo{i,1}.triggerThreshold = handles.inputArtefact.Data{i,1};
    end
catch
    popMsg('Failed in inputArtefact...');
end

guidata(hObject, handles);


function panelClassificationMethod_CreateFcn(hObject, eventdata, handles)


% --- Executes on selection change in chPopup1.
function chPopup1_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns chPopup1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chPopup1
resetAll(hObject, handles);


% --- Executes during object creation, after setting all properties.
function chPopup1_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chPopup2.
function chPopup2_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns chPopup2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chPopup2
resetAll(hObject, handles);


% --- Executes during object creation, after setting all properties.
function chPopup2_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputCOMPORT_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of inputCOMPORT as text
%        str2double(get(hObject,'String')) returns contents of inputCOMPORT as a double
handles.UserData.portHand = sprintf('COM%s', get(hObject,'String'));
resetAll(hObject, handles);


% --- Executes during object creation, after setting all properties.
function inputCOMPORT_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when entered data in editable cell(s) in inputFilter.

function inputFilter_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
filterCutoffFreq = cell2mat(get(hObject,'Data'));
if all(filterCutoffFreq > 0) && sign(diff(filterCutoffFreq)) == -1
    popMsg('Lowpass Cutoff Freq smaller than Highpass Cutoff Freq...');
    hObject.Data{2,1} = hObject.Data{1,1};
end
resetAll(hObject, handles);

% --- Executes when selected object is changed in buttonGroupChannelMode.
function buttonGroupChannelMode_SelectionChangedFcn(hObject, eventdata, handles)
handles.UserData.numChannelDisp = str2num(hObject.String(1));
disp([hObject.String, ' has been selected...']);
resetAll(hObject, handles);


% --- Executes when selected object is changed in buttonGroupSMChannel.
function buttonGroupSMChannel_SelectionChangedFcn(hObject, eventdata, handles)
handles.UserData.multiChannelFlag = ~isempty(strfind(hObject.String, 'Multi'));
disp([hObject.String, ' has been selected...']);
resetAll(hObject, handles);

% --- Executes during object deletion, before destroying properties.
function inputBlankSize_DeleteFcn(hObject, eventdata, handles)
try
fclose(handles.UserData.tB);
for i = 1:length(handles.UserData.classInfo)
    fwrite(handles.UserData.classInfo{i,1}.t,'DISCONNECT!!!!!!');
    fclose(handles.UserData.classInfo{i,1}.t);
end
catch
end

% --- Executes on button press in burstTrimmingBox.
function burstTrimmingBox_Callback(hObject, eventdata, handles)
% hObject    handle to burstTrimmingBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Source.Value
    disp([hObject.String, ' has been selected...']);
else
    disp([hObject.String, ' has been de-selected...']);
end
resetAll(hObject, handles);

% --- Executes on button press in TKEOmoreBox.
function TKEOmoreBox_Callback(hObject, eventdata, handles)
% hObject    handle to TKEOmoreBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Source.Value
    disp([hObject.String, ' has been selected...']);
else
    disp([hObject.String, ' has been de-selected...']);
end
resetAll(hObject, handles);

% --- Executes on button press in optimizeBox.
function optimizeBox_Callback(hObject, eventdata, handles)
% hObject    handle to optimizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Source.Value
    disp([hObject.String, ' has been selected...']);
else
    disp([hObject.String, ' has been de-selected...']);
end
resetAll(hObject, handles);

%% Private functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setupUserData(hObject, handles)
handles.UserData = struct(...
    'startAllFlag', 0,...
    'stopFlag', 1,...
    'openPortFlag', 0,...
    'stopAll', 0,...
    'multiChannelFlag', ~isempty(strfind(handles.buttonGroupSMChannel.SelectedObject.String, 'Multi')),...
    'bionicHandConnection',0,...
    'portHand',sprintf('COM%s', handles.inputCOMPORT.String),...
    'numChannelDisp', 4,...
    'featuresID', [5,8]);
handles.UserData.chPorts = struct(...
    'Ch1',1340,...
    'Ch2',1341,...
    'Ch3',1342,...
    'Ch4',1343,...
    'Ch5',1344,...
    'Ch6',1345,...
    'Ch7',1346,...
    'Ch8',1347,...
    'Ch9',1348,...
    'Ch10',1349);

guidata(hObject, handles);

function [fullfilenameFeature, fullfilenameClass] = saveBurstsInfo(signal, signalClassificationInfo, saveFileName, markBurstInAllChannels)
featuresForClassification = [5,8];  % selected features for classification        
numFile = length(signalClassificationInfo);

% Make a folder to store the features and corresponding classes
filepath = fileparts(saveFileName{1,1});
filepath = fullfile(filepath, 'classificationTmp');
if ~exist(filepath,'file')
    mkdir(filepath);
end

[~, filename] = fileparts(saveFileName{1,1});

if markBurstInAllChannels
    for i = 1:numFile
        featureStruct = signalClassificationInfo(i,1).features;
        featureStruct = rmfield(featureStruct, 'dataAnalysed');  % to make it able to build a full table
        featureTable = struct2table(featureStruct);
        
        feature{i,1} = table2array(featureTable(:,featuresForClassification));  % get the target features
        
        % get corresponding class
        class{i,1} = i * ones(size(feature{i,1},1),1);
    end

    feature = vertcat(feature{:,1});
    class = vertcat(class{:,1});
    numClassUnique = length(unique(class));
    
    timeStamps = time2string();
    fullfilenameFeature{1,1} = fullfile(filepath,sprintf('featuresCha%d_%s_%s.csv', numClassUnique, filename, timeStamps));
    fullfilenameClass{1,1} = fullfile(filepath,sprintf('classCha%d_%s_%s.csv', numClassUnique, filename, timeStamps));
    
    fullfilenameFeature{1,1} = strrep(fullfilenameFeature{1,1}, ' ', '_');
    fullfilenameClass{1,1} = strrep(fullfilenameClass{1,1}, ' ', '_');

    
    % save features and classes
    csvwrite(fullfilenameFeature{1,1}, feature)
    disp(['Saved ', fullfilenameFeature{1,1}, '...']);
    csvwrite(fullfilenameClass{1,1}, class)
    disp(['Saved ', fullfilenameClass{1,1}, '...']);
    
else
    
    for i = 1:numFile
        numClass = 2;

        featureStruct = signalClassificationInfo(i,1).features;
        featureStruct = rmfield(featureStruct, 'dataAnalysed');  % to make it able to build a full table
        featureTable = struct2table(featureStruct);
        
        featureRaw = table2array(featureTable(:,featuresForClassification));  % get the target features
        featureRaw = featureRaw(:,i:numFile:end);  % get the target channel
        feature = reshape(featureRaw,[],2);  % reshape into columns of different features
        feature = omitNan(feature,2,'any');
        
        % get corresponding class
        class = [];
        count = numClass-1;
        for j = 1:numClass
            featureTemp = featureRaw(:,j);
            class = vertcat(class, repmat(j+count, sum(all([~isnan(featureTemp), featureTemp ~= 0], 2)), 1));
            count = count - 2;
        end
        
        timeStamps = time2string();
        fullfilenameFeature{i,1} = fullfile(filepath,sprintf('featuresCh%d0_%s_%s.csv', signal(i,1).channel(1,i), filename, timeStamps));
        fullfilenameClass{i,1} = fullfile(filepath,sprintf('classCh%d0_%s_%s.csv', signal(i,1).channel(1,i), filename, timeStamps));
        
        fullfilenameFeature{i,1} = strrep(fullfilenameFeature{i,1}, ' ', '_');
        fullfilenameClass{i,1} = strrep(fullfilenameClass{i,1}, ' ', '_');
        
        % save features and classes
        csvwrite(fullfilenameFeature{i,1}, feature)
        disp(['Saved ', fullfilenameFeature{i,1}, '...']);
        csvwrite(fullfilenameClass{i,1}, class)
        disp(['Saved ', fullfilenameClass{i,1}, '...']);
    end
end

popMsg('Features and Classes saving finished...');


function getPythonClassifier(fullfilenameFeature, fullfilenameClass)
% clear all the existing saved classifiers
% cwd = pwd;
% cd(fileparts(fullfilenameFeature{1,1}))
% savedClassifier = dir('*.sav');  % get all the saved classifier
% for i = 1:length(savedClassifier)
%     delete(savedClassifier(i,1).name)
% end

% train python classifier
for i = 1:length(fullfilenameFeature)
    systemCmd = sprintf('python %s %s %s', fullfile('C:', 'classification_training.py'), fullfilenameFeature{i,1}, fullfilenameClass{i,1});
    system(systemCmd)
end

popMsg('Saved Classifier...');

% transfer classifier to rpi
cwd = pwd;
filepath = fileparts(fullfilenameFeature{1,1});
cd(filepath)
savedClassifier = dir('*.sav');  % get all the saved classifier
savedNorm = dir('norms*');
cd(cwd)

% get the generated .sav files
savedClassifierTable = struct2table(savedClassifier);
savedNormTable = struct2table(savedNorm);

singleChannelFlag = isempty(strfind(fullfilenameFeature{1,1},'Cha'));
if singleChannelFlag  % single-channel
    targetClassifier = savedClassifierTable(isempty(strfind(savedClassifierTable.name,'classifierCha')),1);
    targetNorm = savedNormTable(isempty(strfind(savedNormTable.name,'normsCha')),1);
    numClassifier = length(targetClassifier.name);
else  % multi-channel
    targetClassifier = savedClassifierTable(~isempty(strfind(savedClassifierTable.name,'classifierCha')),1);
    targetNorm = savedNormTable(~isempty(strfind(savedNormTable.name,'normsCha')),1);
    numClassifier = 1;
end

for i = 1:numClassifier
    % IMPORTANT! download pscp in order to use this command
    try  % for Windows
        % transfer classifier
        if iscell(targetClassifier(i,1).name)
            targetClassifierFilename = fullfile(filepath, targetClassifier(i,1).name{1,1});
        else
            targetClassifierFilename = fullfile(filepath, targetClassifier(i,1).name);
        end
        systemCmd = sprintf('pscp -pw raspberry -scp %s pi@192.168.4.3:~/classificationTmp/', targetClassifierFilename);
        status = system(systemCmd);
        if ~status  % failed to transfer
            popMsg(sprintf('Successfully transfered %s...', targetClassifierFilename));
        else
            popMsg(sprintf('failed to transfer %s...', targetClassifierFilename));
            break
        end
        
        % transfer norms
        if iscell(targetNorm(i,1).name)
            targetNormFilename = fullfile(filepath, targetNorm(i,1).name{1,1});
        else
            targetNormFilename = fullfile(filepath, targetNorm(i,1).name);
        end
        systemCmd = sprintf('pscp -pw raspberry -scp %s pi@192.168.4.3:~/classificationTmp/', targetNormFilename);
        status = system(systemCmd);
        if ~status  % failed to transfer
            popMsg(sprintf('Successfully transfered %s...', targetNormFilename));
        else
            popMsg(sprintf('failed to transfer %s...', targetNormFilename));
            break
        end
    catch
        disp('Using Linux command...')
        try  % for Linux
            systemCmd = sprintf('sshpass -p raspberry scp %s pi@192.168.4.3:~/classificationTmp/', fullfile(filepath, targetClassifier(i,1).name{1,1}));
            system(systemCmd)
        catch
            popMsg('failed to transfer classifiers...')
            break
        end
        try  % for Linux
            systemCmd = sprintf('sshpass -p raspberry scp %s pi@192.168.4.3:~/classificationTmp/', fullfile(filepath, targetNorm(i,1).name{1,1}));
            system(systemCmd)
        catch
            popMsg('failed to transfer norms...')
            break
        end
    end
end

function resetAll(hObject, handles)
disp('Program stopped...')

handles.dispPrediction.String = num2str(zeros(1,handles.UserData.numChannelDisp));
handles.dispStatus.String = 'Program stopped...';
handles.buttonStartStop.String = 'Start';
handles.buttonStartStop.ForegroundColor = [0,190/256,0];
handles.UserData.stopFlag = 1;
handles.UserData.openPortFlag = 0;

handles.tableThresh.Data = [];
handles.inputArtefact.Data = [];
for i = 1:handles.UserData.numChannelDisp
    handles.tableThresh.Data{i,1} = Inf;
    handles.inputArtefact.Data{i,1} = nan;
end

try
    fwrite(handles.UserData.tB,[handles.UserData.parameters.channelEnable,0]); % to disable all channels
catch
end

try
    writeToHand(handles.UserData.tH,'0');
    closeBionicHand(handles.UserData.tH);
catch
end

drawnow
guidata(hObject, handles);


function predictClassAll = runProgram(hObject, handles, predictClassAll)
% try
    for i = 1:handles.UserData.parameters.numChannel
        readSample(handles.UserData.classInfo{i,1});
        %             detectBurst(handles.UserData.classInfo{i,1});
        classifyBurst(handles.UserData.classInfo{i,1});
        if predictClassAll(1,i) ~= handles.UserData.classInfo{i,1}.predictClass % update if state changed
            timing = tic;
            predictClassAll(1,i) = handles.UserData.classInfo{i,1}.predictClass;
            predictClassTemp = predictClassAll;
%             if all(predictClassAll(1:2))
%                 predictClassTemp(2) = 0;
%             end
%             if all(predictClassAll(3:4))
%                 predictClassTemp(4) = 0;
%             end
            handles.dispPrediction.String = num2str(predictClassTemp);
            replyPredictionDec = bi2de(predictClassTemp,'right-msb');
            fwrite(handles.UserData.tB,[handles.UserData.parameters.channelEnable,replyPredictionDec]); % to enable the channel
            drawnow
            
            % write data to robot hand
            if ~handles.UserData.bionicHandConnection && ~isequal(handles.UserData.portHand(4:end), 'nan')
                try
                    if handles.UserData.parameters.numChannel == 2 % add some space between the two channels
                        writeToHand(handles.UserData.tH,...
                            num2str(...
                            bi2de([predictClassTemp(1),[0,0],predictClassTemp(2)],'right-msb')...
                            ));
                    else
                        writeToHand(handles.UserData.tH,num2str(replyPredictionDec))
                    end
                catch
                    popMsg('Failed to write data to hand...');
                end
            end
            
            drawnow
            disp(toc(timing));
        end
        
        %             disp(['Class ',num2str(i),' prediction: ',num2str(handles.UserData.classInfo{i,1}.predictClass)]);
        %             elapsedTime{i,1} = [elapsedTime{i,1};toc(t)];
    end
    
% catch
%     resetAll(hObject, handles)
%     handles.UserData.startAllFlag = 0;
%     popMsg('Wrong selection, please start over...');
%     drawnow
% end
drawnow
    

function handles = setupClassifier(handles)
%% Parameters
switch handles.UserData.numChannelDisp
    case 2
        parameters = struct(...
            'overlapWindowSize',50,... % ms
            'ports',[handles.UserData.chPorts.(handles.chPopup1.String{handles.chPopup1.Value,1}),...
            handles.UserData.chPorts.(handles.chPopup2.String{handles.chPopup2.Value,1})],...
            'replyPort',1300,...
            'channelEnable',251);
    case 4
        parameters = struct(...
            'overlapWindowSize',50,... % ms
            'ports',1343:1346,...
            'replyPort',1300,...
            'channelEnable',251);
end

parameters.numChannel = length(parameters.ports);

for i = 1:parameters.numChannel
    classInfo{i,1} = classOnlineClassification(); % Initiatialize the object

    guiInput = struct(...
        'predictionMethod',handles.panelClassificationMethod.SelectedObject.String,...
        'thresholds',handles.tableThresh.Data{i,1},...
        'windowSize',str2num(handles.inputWindowSize.String),...
        'blankSize',str2num(handles.inputBlankSize.String),...
        'triggerThreshold',handles.inputArtefact.Data{i,1},...
        'highpassCutoffFreq',handles.inputFilter.Data{1,1},...
        'lowpassCutoffFreq',handles.inputFilter.Data{2,1},...
        'samplingFreq',17850);
    
    setBasicParameters(classInfo{i,1},handles.UserData.classifierParameters{i,1},parameters,guiInput);
            
    setTcpip(classInfo{i,1},'127.0.0.1',parameters.ports(1,i),'NetworkRole','client','Timeout',1);

    % Streaming data
    tcpip(classInfo{i,1}); % open channel port
    openPort(classInfo{i,1});
end

% open reply port
try
    tB = tcpip('127.0.0.1',parameters.replyPort,'NetworkRole','client','Timeout',1);
    disp(['Opened port ',num2str(parameters.channelEnable),' as reply port...'])
    fopen(tB);
catch
    disp(['Reply port ',num2str(parameters.channelEnable),' is not open yet...'])
end


%%  Run the online classification
%     clearvars -except parameters classInfo tB

% elapsedTime = cell(parameters.numChannel,1);

handles.UserData.openPortFlag = 1;
handles.UserData.classInfo = classInfo;
handles.UserData.parameters = parameters;
handles.UserData.tB = tB;





