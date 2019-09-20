function varargout = RAMPS_GUI(varargin)
% RAMPS_GUI MATLAB code for RAMPS_GUI.fig
%      RAMPS_GUI, by itself, creates a new RAMPS_GUI or raises the existing
%      singleton*.
%
%      H = RAMPS_GUI returns the handle to a new RAMPS_GUI or the handle to
%      the existing singleton*.
%
%      RAMPS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RAMPS_GUI.M with the given input arguments.
%
%      RAMPS_GUI('Property','Value',...) creates a new RAMPS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RAMPS_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RAMPS_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RAMPS_GUI

% Last Modified by GUIDE v2.5 18-Sep-2014 12:07:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RAMPS_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RAMPS_GUI_OutputFcn, ...
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


% --- Executes just before RAMPS_GUI is made visible.
function RAMPS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RAMPS_GUI (see VARARGIN)

% Choose default command line output for RAMPS_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(hObject, 'Interruptible', 'on');

% -------------------------------------------------------------------------
% UIWAIT makes RAMPS_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RAMPS_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbtnNBIData_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');

setappdata(0,'Options',Options);
NBIDataGui();

function pushbtnGeo_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
% Enbl = get(hObject, 'Enable');
% guidata(Enbl);

if ~isfield(Options.handles, 'guiUserInputDeck')
    UserInputDeck();
else
    if strcmp(get(Options.handles.guiUserInputDeck, 'visible'), 'on')
        set(Options.handles.guiUserInputDeck, 'Visible', 'off');
    else
        set(Options.handles.guiUserInputDeck, 'Visible', 'on');
    end
end

if get(hObject, 'Value') == 1
    set(handles.pushbtnDiaphragm, 'Enable', 'on');
end 

function pushbtnDiaphragm_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');

if ~isfield(Options.handles, 'guiUserInputDiaSection')
    UserInputDiaSection();
else
    if strcmp(get(Options.handles.guiUserInputDiaSection, 'visible'), 'on')
        set(Options.handles.guiUserInputDiaSection, 'Visible', 'off');
    else
        set(Options.handles.guiUserInputDiaSection, 'Visible', 'on');
    end
end

if get(hObject, 'Value') == 1
    set(handles.pushbtnGirders, 'Enable', 'on');
end 

function pushbtnGirders_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
Parameters = getappdata(0, 'Parameters');

if ~isfield(Options.handles, 'guiUserInputBeamSection')
    switch Parameters.structureType
        case 'Steel'
            UserInputBeamSection_gui();
        case 'Prestressed'
            UserInputPrestressedSection_gui();
    end    
else
    if strcmp(get(Options.handles.guiUserInputBeamSection, 'visible'), 'on')
        set(Options.handles.guiUserInputBeamSection, 'Visible', 'off');
    else
        set(Options.handles.guiUserInputBeamSection, 'Visible', 'on');
    end
end

if get(hObject, 'Value') == 1
    set(handles.pushbtnFEMModel, 'Enable', 'on');
end 

function pushbtnBuildSt7Model_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

CloseAndUnload(Options.St7.uID);
InitializeSt7();

% Check if structure number available
if strcmp(Options.Geo, 'NBI')
    ModelName = Parameters.StructureNumber;
else
    ModelName = 'Bridge_1';
end

% Ask for file name and save dir
try
    [ModelName, ModelPath] = uiputfile([Options.SaveDir '*.st7'],'Choose Save Directory', ModelName);
catch %#ok<*CTCH>
    CloseAndUnload(Options.St7.uID)
    return
end

if isempty(ModelName)
    CloseAndUnload(Options.St7.uID)
    return
end

% Set options
Options.modelOpen = 1;
Options.ModelPath = ModelPath;
Options.ModelName = ModelName(1:end-4);

% Build Model
h = waitbar(0.3,'Please Wait While Bridge Model is Created...');

global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU
ScratchPath = 'C:\Temp\';
Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];

NewModel(Options.St7.uID, Options.ModelPath, Options.ModelName, ScratchPath, Units)

[Node, Parameters] = ModelGeneration(Options.St7.uID, Options, Parameters);

iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

save([Options.ModelPath Options.ModelName '_Node.mat'],'Node','-v7');
save([Options.ModelPath Options.ModelName '_Para.mat'], 'Parameters', '-v7');
save([Options.ModelPath Options.ModelName '_Options.mat'], 'Options', '-v7');
clear('Nodes');
close(h);

CloseModelFile(Options.St7.uID);
CloseAndUnload(Options.St7.uID);
St7Start = 1;
InitializeRAMPS([],[], St7Start);

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);
setappdata(0,'Node', Node);

if get(hObject, 'Value') == 1
    set(handles.pushbtnBearings, 'Enable', 'on');
end 

function pushbtnBearings_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');

% Open Model
iErr = calllib('St7API', 'St7OpenFile', Options.St7.uID, [Options.ModelPath Options.ModelName '.st7'], Options.St7.ScratchPath);
HandleError(iErr);

if ~isfield(Options.handles, 'guiUserInputBearings')
    Options.handles.guiUserInputBearings = UserInputBearings_Variable_gui();
    uiwait(Options.handles.guiUserInputBearings);
else
    if strcmp(get(Options.handles.guiUserInputBearings, 'visible'), 'on')
        set(Options.handles.guiUserInputBearings, 'Visible', 'off');
    else
        set(Options.handles.guiUserInputBearings, 'Visible', 'on');
    end
end

% Save model
iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

% Close Model
CloseModelFile(Options.St7.uID);

% set app data
setappdata(0,'Options',Options);

% function pushbtnRating_Callback(hObject, eventdata, handles)
% LoadRating_gui()
% Parameters = getappdata(0,'Parameters');
% Options = getappdata(0,'Options');
% 
% CloseAndUnload(Options.St7.uID);
% InitializeSt7();
% 
% %% Open file and save copy
% % Ask for file name and save dir
% try
%     [ModelName, ModelPath] = uigetfile([Options.SaveDir '*.st7'],'Choose Model File');
% catch %#ok<*CTCH>
%     return
% end
% 
% % Set options
% Options.modelOpen = 1;
% Options.ModelPath = ModelPath(1:end-8);
% Options.ModelName = ModelName(1:end-4);
% 
% % Load data
% load([Options.ModelPath '\' Options.ModelName '_Para.mat']);
% load([Options.ModelPath '\' Options.ModelName '_Options.mat']);
% load([Options.ModelPath '\' Options.ModelName '_Node.mat']);
% 
% 
% %% Update Parameters
% % Get parameters to update
% UserInputParameters();
% 
% % Run Model Correlation
% fprintf('\nRunning Model Correlation Sequence:\n');
% Output = ModelCorrelation(uID, Options, Node, Parameters);
% fprintf('Done\n\n');

function pushbtnImportExport_Callback(hObject, eventdata, handles)
ImportExportGui();

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% Get and remove app data
appD = getappdata(0);
names = fieldnames(appD);

for i = 1:length(names)
    rmappdata(0, names{i});
end

CloseAndUnload(1);

function pushbtnStID_Det_Callback(hObject, eventdata, handles)
SingleModelCorrelation_gui();

% --- Executes on button press in pusbtnNewModel.
function pusbtnNewModel_Callback(hObject, eventdata, handles)
Options = getappdata(0, 'Options');

if get(hObject, 'Value') == 1
    set([handles.pushbtnNBIData, handles.pushbtnGeo], 'Enable', 'on');
    set([handles.pushbtnDiaphragm, handles.pushbtnBearings,...
        handles.pushbtnGirders, handles.pushbtnFEMModel], 'Enable', 'off');
    if isappdata(0, 'P_temp')
        rmappdata(0, 'P_temp');
    end
end

if isfield(Options.handles, 'guiUserInputDeck')
    delete(Options.handles.guiUserInputDeck);
    Options.handles = rmfield(Options.handles, 'guiUserInputDeck');
end

if isfield(Options.handles, 'guiUserInputDiaSection')
    delete(Options.handles.guiUserInputDiaSection);
    Options.handles = rmfield(Options.handles, 'guiUserInputDiaSection');
end

if isfield(Options.handles, 'guiUserInputBearings')
    delete(Options.handles.guiUserInputBearings);
    Options.handles = rmfield(Options.handles, 'guiUserInputBearings');
end

if isfield(Options.handles, 'guiUserInputBeamSection')
    delete(Options.handles.guiUserInputBeamSection);
    Options.handles = rmfield(Options.handles, 'guiUserInputBeamSection');
end

[Parameters, Options] = InitializeRAMPS([],[],1);
setappdata(0, 'Options', Options);
setappdata(0, 'Parameters', Parameters);

function pushbtnSensitivity_Callback(hObject, eventdata, handles)


function pushbtnBayes_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbtnRating.
function pushbtnRating_Callback(hObject, eventdata, handles)
LoadRating_gui();
% hObject    handle to pushbtnRating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
