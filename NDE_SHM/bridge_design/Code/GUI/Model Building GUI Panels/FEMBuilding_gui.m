function varargout = FEMBuilding_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FEMBuilding_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @FEMBuilding_gui_OutputFcn, ...
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

function FEMBuilding_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for FEMBuilding_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = FEMBuilding_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function edit_ModelName_Callback(hObject, eventdata, handles)

function edit_ModelName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pb_Generate_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

CloseAndUnload(Options.St7.uID);
InitializeSt7();

% Check if structure number available
ModelName = get(handles.edit_ModelName,'string');
Parameters.ModelName = ModelName;
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

function pb_ViewModel_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');

CloseAndUnload(Options.St7.uID);
InitializeSt7();

% Open Model
iErr = calllib('St7API', 'St7OpenFile', Options.St7.uID, [Options.ModelPath Options.ModelName '.st7'], Options.St7.ScratchPath);
HandleError(iErr);


FEModelWindow_gui();

function pb_bearings_Callback(hObject, eventdata, handles)

Parameters = getappdata(0,'Parameters');
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
