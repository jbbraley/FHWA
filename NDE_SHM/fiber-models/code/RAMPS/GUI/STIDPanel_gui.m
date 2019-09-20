function varargout = STIDPanel_gui(varargin)
% STIDPANEL_GUI MATLAB code for STIDPanel_gui.fig
%      STIDPANEL_GUI, by itself, creates a new STIDPANEL_GUI or raises the existing
%      singleton*.
%
%      H = STIDPANEL_GUI returns the handle to a new STIDPANEL_GUI or the handle to
%      the existing singleton*.
%
%      STIDPANEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIDPANEL_GUI.M with the given input arguments.
%
%      STIDPANEL_GUI('Property','Value',...) creates a new STIDPANEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STIDPanel_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STIDPanel_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STIDPanel_gui

% Last Modified by GUIDE v2.5 05-Feb-2015 11:04:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STIDPanel_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @STIDPanel_gui_OutputFcn, ...
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

% Opening/Closing Functions -----------------------------------------------
function STIDPanel_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for STIDPanel_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Initialize Work Environment
% Initial values
St7Start = 1;
Options = [];
Parameters = [];

% Initiaqlize RAMPS
hObject = handles.listboxNotificationPanel;
msg = 'Initializing RAMPS...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

[Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

hObject = handles.listboxNotificationPanel;
msg = 'DONE';
type = 'append';
UpdateNotificationPanel(hObject, msg, type);

% Set data to root
setappdata(0, 'Parameters', Parameters);
setappdata(0, 'Options', Options)

function varargout = STIDPanel_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function guiSTIDPanel_gui_CloseRequestFcn(hObject, eventdata, handles)
% Get options from app data to close and unload
Options = getappdata(0,'Options');
CloseAndUnload(Options.St7.uID);
RemoveAppData();

% delete GUI
delete(hObject);

% Load Files --------------------------------------------------------------
function pushbtnLoadModelFile_Callback(hObject, eventdata, handles)
try
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'Model Loading:...';
    type = 'new';
    UpdateNotificationPanel(hObject, msg, type);
    
    % Get data from root
    Options = getappdata(0, 'Options');
    Parameters = getappdata(0, 'Parameters');
    
    % get files from user
    [filename, pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
        'Select model file', ...
        'MultiSelect' , 'off');
    
    % error screen no selection
    if pathname == 0
        return
    end
    
    % Create full file name
    fullnames = {fullfile(pathname,filename)};
    
    % Define Model Name
    fname = filename(1:end-4);
    
    % Set model and path names to options
    Options.St7.FileName = fname;
    Options.St7.PathName = pathname;
    
    % Load St7 Files
    FileName = Options.St7.FileName;
    PathName = Options.St7.PathName;
    St7OpenModelFile(Options.St7.uID, PathName, FileName, Options.St7.ScratchPath);
    
    % Save temp copy of St7 file in workspace and open temp copy
    FileName = [fname '_temp'];
    PathName = Options.St7.ScratchPath;
    St7SaveFileAs(Options.St7.uID, PathName, FileName);
    
    % Close Original
    St7CloseModelFile(Options.St7.uID);
    
    % Open New
    St7OpenModelFile(Options.St7.uID, PathName, FileName, Options.St7.ScratchPath);    
    Options.FileOpen.St7Model = 1;
    
    % set data to root
    setappdata(0, 'Options', Options);
    setappdata(0, 'Parameters', Parameters);
    
    % update listbox string
    set(handles.listboxModelFile, 'string', fullnames);
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = [fname '...DONE'];
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
    
    % Handle Metadata
    pushbtnLoadMetaData_Callback(handles.pushbtnLoadMetaData, eventdata, handles)
catch
    Options.FileOpen.St7Model = 0;
    setappdata(0, 'Options', Options);
    
    % update listbox string
    set(handles.listboxModelFile, 'string', '');
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
    
    CloseAndUnload(Options.St7.uID);
    [Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);
    
    % Set data to root
    setappdata(0, 'Parameters', Parameters);
    setappdata(0, 'Options', Options)
end    

function listboxModelFile_Callback(hObject, eventdata, handles)

function pushbtnLoadMetaData_Callback(hObject, eventdata, handles)
% Display metadata loading messages
hObject = handles.listboxNotificationPanel;
msg = 'Meta Data Loading...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

try
    % Get data from root
    Options = getappdata(0, 'Options');
    Parameters = getappdata(0, 'Parameters');
    
    % Check for metadata
    % Check if filenames exist in directory
    % Try to get filename if it's loaded...if metadata was cleared you have
    % to pick fiels manually
    fname = Options.St7.FileName;
    pathname = Options.St7.PathName;
    
    if exist([pathname fname '_Para.mat'],'file')==2
        meta_fnames{1} = fullfile(pathname,[fname '_Para.mat']);
    end
    if exist([pathname fname '_Node.mat'],'file')==2
        meta_fnames{2} = fullfile(pathname,[fname '_Node.mat']);
    end
    
    % If corresponding meta files do not exist in directory prompt for
    % selection
    % If they exist, save app data
    if ~exist('meta_fnames','var') || length(meta_fnames)~=2
        % Ask for files
        [meta_filename, meta_pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
            'Select files', ...
            'MultiSelect' , 'on');
        
        % Form cell array of filenames
        for ii = 1:length(meta_filename)
            meta_fnames{ii} = fullfile(meta_pathname, meta_filename{ii});
        end
    end
    
    % Load meta .mat files
    for ii = 1:length(meta_fnames)
        try
            load(meta_fnames{ii}); % load file
            msg{ii} = meta_fnames{ii};
            
            % Set filenames and file open status to options
            if all(ismember('Para',meta_fnames{ii})) % checks what type of metadata
                Options.FileOpen.Parameters = 1;
                Options.FileNames.Parameters = meta_fnames{ii};
            elseif all(ismember('Node',meta_fnames{ii}))
                Options.FileOpen.Node = 1;
                Options.FileNames.Node = meta_fnames{ii};
            end
            
        catch
            if all(ismember('Para',meta_fnames{ii}))
                Options.FileOpen.Parameters = 0;
                Options.FileNames.Parameters = [];
            elseif all(ismember('Node',meta_fnames{ii}))
                Options.FileOpen.Node = 0;
                Options.FileNames.Node = [];
            end
        end
    end
    
    % Set filename and Pathname to Options in case loaded options file doesn't
    % match
    Options.St7.FileName = fname;
    Options.St7.PathName = pathname;
    
    % Save data to root
    setappdata(0,'Parameters',Parameters);
    setappdata(0,'Options',Options);
    setappdata(0,'Node',Node);
    
    % display file names
    set(handles.listboxMetaData, 'String', meta_fnames);
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
catch
    % display file names
    set(handles.listboxMetaData, 'String', '');
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function pushbtnClearMetaData_Callback(hObject, eventdata, handles)
% Clear meta data files from memory
clear Parameters Options Node

% Remove app data
rmappdata(0, 'Parameters');
rmappdata(0, 'Options');
rmappdata(0, 'Node');

% Clear meta data list box
msg = [];
set(handles.listboxMetaData, 'String', msg);

% Notification Panel
hObject = handles.listboxNotificationPanel;
msg = 'Meta Data Cleared.';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

% Reset Basic app data
St7Start = 0;
Options = [];
Parameters = [];
[Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

% set data to root
setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

function listboxMetaData_Callback(hObject, eventdata, handles)

function pushbtnLoadTestData_Callback(hObject, eventdata, handles)
% Notification Panel
hObject = handles.listboxNotificationPanel;
msg = 'Test Data Loading...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

try
    % Get data from root
    Options = getappdata(0, 'Options');
    
    % get files from user
    [filename, pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
        'Select Test File', ...
        'MultiSelect' , 'off');
    
    % error screen no selection
    if pathname == 0
        return
    end
    
    % Create full file name
    fullnames = {fullfile(pathname,filename)};
    
    % Check if file is formatted or need to be imported
    loadRes = load(fullnames{1});
    if ~isfield(loadRes, 'testData') % not in imported format
        % Check for Metadata Files
        if ~Options.FileOpen.Parameters || ~Options.FileOpen.Node
            pushbtnLoadMetaData_Callback(handles.pushbtnLoadMetaData, eventdata, handles)
        end
        
        loadRes = ImportTestData_gui(loadRes.results);
    end
    
    % Put testData in root
    setappdata(0, 'testData', loadRes.testData);
    
    % update listbox string
    set(handles.listboxTestData, 'string', fullnames);
    
    % Set data to root
    setappdata(0,'Options',Options);
    
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
catch
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED!';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function listboxTestData_Callback(hObject, eventdata, handles)

% Notification Panel ------------------------------------------------------

function pushbtnClearNotificationPanel_Callback(hObject, eventdata, handles)

function listboxNotificationPanel_Callback(hObject, eventdata, handles)

% Subfunction Buttons -----------------------------------------------------

function pushbtnParameters_Callback(hObject, eventdata, handles)

function pushbtnBoundaryConditions_Callback(hObject, eventdata, handles)

function pushbtnMassCorrelation_Callback(hObject, eventdata, handles)

function pushbtnParameterCorrelation_Callback(hObject, eventdata, handles)

function pushbtnFEModelWindow_Callback(hObject, eventdata, handles)
FEModelWindow_gui();

% --- Executes on button press in pushbtnNBIData.
function pushbtnNBIData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnNBIData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnGeo.
function pushbtnGeo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnGeo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnDiaphragm.
function pushbtnDiaphragm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnDiaphragm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnGirders.
function pushbtnGirders_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnGirders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnBuildSt7Model.
function pushbtnBuildSt7Model_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnBuildSt7Model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnSaveMetaData.
function pushbtnSaveMetaData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnSaveMetaData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnSaveModelFile.
function pushbtnSaveModelFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnSaveModelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbtnRateModel.
function pushbtnRateModel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnRateModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnNewModel.
function pushbtnNewModel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnNewModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbtnTestModelComparison.
function pushbtnTestModelComparison_Callback(hObject, eventdata, handles)
% hObject    handle to pushbtnTestModelComparison (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
