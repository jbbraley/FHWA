function varargout = SingleModelCorrelation_gui(varargin)
% SINGLEMODELCORRELATION_GUI MATLAB code for SingleModelCorrelation_gui.fig
%      SINGLEMODELCORRELATION_GUI, by itself, creates a new SINGLEMODELCORRELATION_GUI or raises the existing
%      singleton*.
%
%      H = SINGLEMODELCORRELATION_GUI returns the handle to a new SINGLEMODELCORRELATION_GUI or the handle to
%      the existing singleton*.
%
%      SINGLEMODELCORRELATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLEMODELCORRELATION_GUI.M with the given input arguments.
%
%      SINGLEMODELCORRELATION_GUI('Property','Value',...) creates a new SINGLEMODELCORRELATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SingleModelCorrelation_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SingleModelCorrelation_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SingleModelCorrelation_gui

% Last Modified by GUIDE v2.5 23-Sep-2014 15:51:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SingleModelCorrelation_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SingleModelCorrelation_gui_OutputFcn, ...
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


% --- Executes just before SingleModelCorrelation_gui is made visible.
function SingleModelCorrelation_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SingleModelCorrelation_gui (see VARARGIN)

% Choose default command line output for SingleModelCorrelation_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% get app data
Parameters = getappdata(0,'Parameters');

% Set Initial Values for Parameters
set(handles.checkboxUpdate_Deck, 'Value', 1);
set(handles.checkboxUpdate_Beam, 'Value', 1);
set(handles.checkboxUpdate_Dia, 'Value', 1);
set(handles.checkboxUpdate_Barrier, 'Value', 1);
set(handles.checkboxUpdate_Sidewalk, 'Value', 1);
set(handles.checkboxCompositeAction, 'Value', 1);

% Set default tolerances
set(handles.editTolFun, 'string',0.001);
set(handles.editTolX,'string',0.001);

% Set default scale
set(handles.editScale,'string',100);

% set buttons to enable "on"
set(handles.pushbtnBoundaryConditions, 'Enable', 'on');
set(handles.pushbtnStartCorrelation, 'Enable', 'on');
set(handles.pushbtnParameterSensitivity, 'enable', 'on');

% Set frequency weighting pop-up
freqWeightList = {'None', 'Inverse Order'};
set(handles.popupfreqWeight, 'String', freqWeightList);

formatColorScheme(hObject);

function varargout = SingleModelCorrelation_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function guiSingleModelCorrelation_CloseRequestFcn(hObject, eventdata, handles)
try
    % Close St7 Model File
    Options = getappdata(0,'Options');
    CloseModelFile(Options.St7.uID);
catch
end
delete(hObject);

%--------------------------------------------------------------------------
function pushbtnLoadFiles_Callback(hObject, eventdata, handles)
% Get experimental mode sahpes to use for updating as well as files
h = ChooseExperimentalModeShapes_gui();
uiwait(h);

% Get Options
Options = getappdata(0,'Options');

% Save temporary file and close original
pname_update = Options.St7.ScratchPath;
fname_update = [Options.St7.FileName(1:end-4) '_tmp.st7'];
St7SaveFileAs(Options.St7.uID, pname_update, fname_update);
CloseModelFile(Options.St7.uID);
% Open tmp
Options.St7.PathName = pname_update;
Options.St7.FileName = fname_update;
OpenModelFile(Options.St7.uID, Options.St7.PathName, Options.St7.FileName, Options.St7.ScratchPath);

% Populate frequency table
meshData = getappdata(0,'meshData');
testData = getappdata(0,'testData');
freqData = zeros(length(meshData.freq),2);
freqData(:,1) = meshData.freq;
testFreq = testData.freq(Options.Correlation.expModes);
freqData(1:length(testFreq),2) = testFreq;
set(handles.uitableFreq,'data',freqData);

% Update fields for model file name, etc.
set(handles.textModelFile, 'String', [Options.St7.PathName, Options.St7.FileName]);

% Get Parameters
Parameters = getappdata(0, 'Parameters');

% Load Parameter info into starting Parameter slots
set(handles.editDeck_Start, 'String', Parameters.Deck.fc);
set(handles.editBeam_Start, 'String', Parameters.Beam.Ix);
set(handles.editDia_Start, 'String', Parameters.Dia.E);
set(handles.editBarrier_Start, 'String', Parameters.Barrier.fc);
set(handles.editSidewalk_Start, 'String', Parameters.Sidewalk.fc);
set(handles.editComposite_Start, 'String', Parameters.compAction.Ix);

% Load in min and max to parameters using start point
set(handles.editDeck_Min, 'String', num2str(Parameters.Deck.Updating.fc.Alpha(2)*Parameters.Deck.fc));
set(handles.editDeck_Max, 'String', num2str(Parameters.Deck.Updating.fc.Alpha(3)*Parameters.Deck.fc));

set(handles.editBeam_Min, 'String', num2str(Parameters.Beam.Updating.Ix.Alpha(2)*Parameters.Beam.Ix));
set(handles.editBeam_Max, 'String', num2str(Parameters.Beam.Updating.Ix.Alpha(3)*Parameters.Beam.Ix));

set(handles.editDia_Min, 'String', num2str(Parameters.Dia.Updating.E.Alpha(2)*Parameters.Dia.E));
set(handles.editDia_Max, 'String', num2str(Parameters.Dia.Updating.E.Alpha(3)*Parameters.Dia.E));

set(handles.editBarrier_Min, 'String', num2str(10^Parameters.Barrier.Updating.fc.Alpha(2)*Parameters.Barrier.fc));
set(handles.editBarrier_Max, 'String', num2str(10^Parameters.Barrier.Updating.fc.Alpha(3)*Parameters.Barrier.fc));

set(handles.editSidewalk_Min, 'String', num2str(10^Parameters.Sidewalk.Updating.fc.Alpha(2)*Parameters.Sidewalk.fc));
set(handles.editSidewalk_Max, 'String', num2str(10^Parameters.Sidewalk.Updating.fc.Alpha(3)*Parameters.Sidewalk.fc));

set(handles.editComposite_Min, 'String', num2str(Parameters.compAction.Ix*10^Parameters.Sidewalk.Updating.fc.Alpha(2)));
set(handles.editComposite_Max, 'String', num2str(Parameters.compAction.Ix*10^Parameters.Sidewalk.Updating.fc.Alpha(3)));

% set button to enable "off"
set(handles.pushbtnBoundaryConditions, 'Enable', 'on');

% % Update UI
% updateSingleModelCorrUI(handles,Parameters);

function editTestFile_Callback(hObject, eventdata, handles)

function editModelFile_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------

function pushbtnStartCorrelation_Callback(hObject, eventdata, handles)
% get app data
Options = getappdata(0,'Options');
Parameters = getappdata(0,'Parameters');
Node = getappdata(0,'Node');
testData = getappdata(0,'testData');
meshData = getappdata(0,'meshData');

% Get Field Values
[Parameters, Options] = GetFieldValues(Parameters, Options, handles);

% Save temp Parameters file
P_temp = Parameters;

% Prompt for location to save updated model files
% Get st7 file path and name
fname = Options.St7.FileName(1:end-8);
[fname_update, pname_update] = uiputfile('.st7','Save Updated Model',[Options.St7.PathName fname]);

value = get(handles.popupfreqWeight,'value');
string = get(handles.popupfreqWeight,'String');
Options.Correlation.freqWeight = string{value};

% Error Screening
if isempty(Options.Correlation.TolFun) || isempty(Options.Correlation.TolX) || isempty(Options.Analysis.NumModes)
    %Inform User
    fprintf('All Minimization Options must be defined')
    return
end

% Save as new file, close original,
St7SaveFileAs(Options.St7.uID, pname_update, fname_update);
Options.St7.PathName = pname_update;
Options.St7.FileName = fname_update;
CloseModelFile(Options.St7.uID);

% Reset St7 and reload new model file
CloseAndUnload(Options.St7.uID);
InitializeSt7();
OpenModelFile(Options.St7.uID, Options.St7.PathName, Options.St7.FileName, Options.St7.ScratchPath);

% Start Correlation
% update all parameters first.
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);
Parameters = ModelCorrelation(Options.St7.uID, Options, Node, Parameters, testData, meshData, handles);

% Set all update parameters to false
Parameters.Deck.Updating.fc.Update = 0;
Parameters.Beam.Updating.Ix.Update = 0;
Parameters.Dia.Updating.E.Update = 0;
Parameters.Barrier.Updating.fc.Update = 0;
Parameters.Sidewalk.Updating.fc.Update = 0;
Parameters.compAction.Updating.Ix.Update = 0;
Parameters.Bearing.Fixed.Update = [0 0 0 0 0 0 0 0];
Parameters.Bearing.Expansion.Update = [0 0 0 0 0 0 0 0];
    
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);

% Save Parameters, Options, Nodes and St7 File
save([Options.St7.PathName Options.St7.FileName(1:end-4) '_Para.mat'],'Parameters')
save([Options.St7.PathName Options.St7.FileName(1:end-4) '_Options.mat'],'Options')
save([Options.St7.PathName Options.St7.FileName(1:end-4) '_Node.mat'],'Node')
iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

% Save temporary file and close original
pname_update = Options.St7.ScratchPath;
fname_update = [Options.St7.FileName(1:end-4) '_tmp.st7'];
St7SaveFileAs(Options.St7.uID, pname_update, fname_update);
CloseModelFile(Options.St7.uID);
% Open tmp
Options.St7.PathName = pname_update;
Options.St7.FileName = fname_update;
OpenModelFile(Options.St7.uID, Options.St7.PathName, Options.St7.FileName, Options.St7.ScratchPath);

Parameters = P_temp;
SetFieldValues(Parameters, handles);
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);

% -------------------------------------------------------------------------

function [Parameters, Options] = GetFieldValues(Parameters, Options, handles)
% Get Minimization Options
Options.Analysis.NumModes = str2double(get(handles.editNumAnaModes,'String'));
Options.Correlation.TolFun = str2double(get(handles.editTolFun,'String'));
Options.Correlation.TolX = str2double(get(handles.editTolX,'string'));

% Get parameter options
Parameters.Deck.Updating.fc.Update = get(handles.checkboxUpdate_Deck, 'Value');
Parameters.Beam.Updating.Ix.Update = get(handles.checkboxUpdate_Beam, 'Value');
Parameters.Dia.Updating.E.Update = get(handles.checkboxUpdate_Dia, 'Value');
Parameters.Barrier.Updating.fc.Update = get(handles.checkboxUpdate_Barrier, 'Value');
Parameters.Sidewalk.Updating.fc.Update = get(handles.checkboxUpdate_Sidewalk, 'Value');
Parameters.compAction.Updating.Ix.Update = get(handles.checkboxCompositeAction, 'Value');

Parameters.Deck.fc = str2num(get(handles.editDeck_Start, 'String'));
Parameters.Beam.Ix = str2num(get(handles.editBeam_Start, 'String'));
Parameters.Dia.E = str2num(get(handles.editDia_Start, 'String'));
Parameters.Barrier.fc = str2num(get(handles.editBarrier_Start, 'String'));
Parameters.Sidewalk.fc = str2num(get(handles.editSidewalk_Start, 'String'));
Parameters.compAction.Ix = str2num(get(handles.editComposite_Start, 'String'));
 
% Load Parameter info into starting Parameter slots
if Parameters.Deck.Updating.fc.Update
    Parameters.Deck.Updating.fc.Alpha(1) = 1;
    Parameters.Deck.Updating.fc.Alpha(2) = str2num(get(handles.editDeck_Min, 'String'))/Parameters.Deck.fc;
    Parameters.Deck.Updating.fc.Alpha(3) = str2num(get(handles.editDeck_Max, 'String'))/Parameters.Deck.fc;
else
    Parameters.Deck.Updating.fc.Alpha = zeros(1,3);
end

if Parameters.Beam.Updating.Ix.Update 
    Parameters.Beam.Updating.Ix.Alpha(1) = 1;
    Parameters.Beam.Updating.Ix.Alpha(2) = str2num(get(handles.editBeam_Min, 'String'))/Parameters.Beam.Ix;
    Parameters.Beam.Updating.Ix.Alpha(3) = str2num(get(handles.editBeam_Max, 'String'))/Parameters.Beam.Ix;
else
    Parameters.Beam.Updating.Ix.Alpha = zeros(1,3);
end

if Parameters.Dia.Updating.E.Update    
    Parameters.Dia.Updating.E.Alpha(1) = 1;
    Parameters.Dia.Updating.E.Alpha(2) = str2num(get(handles.editDia_Min, 'String'))/Parameters.Dia.E;
    Parameters.Dia.Updating.E.Alpha(3) = str2num(get(handles.editDia_Max, 'String'))/Parameters.Dia.E;
else
    Parameters.Dia.Updating.E.Alpha = zeros(1,3);
end

if Parameters.Barrier.Updating.fc.Update
    Parameters.Barrier.Updating.fc.Alpha(1) = 0;
    Parameters.Barrier.Updating.fc.Alpha(2) = log10(str2num(get(handles.editBarrier_Min, 'String'))/Parameters.Barrier.fc);
    Parameters.Barrier.Updating.fc.Alpha(3) = log10(str2num(get(handles.editBarrier_Max, 'String'))/Parameters.Barrier.fc);
else
    Parameters.Barrier.Updating.fc.Alpha = zeros(1,3);
end

if Parameters.Sidewalk.Updating.fc.Update   
    Parameters.Sidewalk.Updating.fc.Alpha(1) = 0;
    Parameters.Sidewalk.Updating.fc.Alpha(2) = log10(str2num(get(handles.editSidewalk_Min, 'String'))/Parameters.Sidewalk.fc);
    Parameters.Sidewalk.Updating.fc.Alpha(3) = log10(str2num(get(handles.editSidewalk_Max, 'String'))/Parameters.Sidewalk.fc);
else
    Parameters.Sidewalk.Updating.fc.Alpha = zeros(1,3);
end

if Parameters.compAction.Updating.Ix.Update
    Parameters.compAction.Updating.Ix.Alpha(1) = 0; % alphas in log scale
    Parameters.compAction.Updating.Ix.Alpha(2) = log10(str2num(get(handles.editComposite_Min, 'String'))/Parameters.compAction.Ix);
    Parameters.compAction.Updating.Ix.Alpha(3) = log10(str2num(get(handles.editComposite_Max, 'String'))/Parameters.compAction.Ix);
else
    Parameters.Sidewalk.Updating.fc.Alpha = zeros(1,3);
end

% -------------------------------------------------------------------------

function SetFieldValues(Parameters, handles)
% Get parameter options
set(handles.checkboxUpdate_Deck, 'Value', Parameters.Deck.Updating.fc.Update);
set(handles.checkboxUpdate_Beam, 'Value', Parameters.Beam.Updating.Ix.Update);
set(handles.checkboxUpdate_Dia, 'Value', Parameters.Dia.Updating.E.Update);
set(handles.checkboxUpdate_Barrier, 'Value', Parameters.Barrier.Updating.fc.Update);
set(handles.checkboxUpdate_Sidewalk, 'Value', Parameters.Sidewalk.Updating.fc.Update);
set(handles.checkboxCompositeAction, 'Value', Parameters.compAction.Updating.Ix.Update);

set(handles.editDeck_Start, 'String', num2str(Parameters.Deck.fc));
set(handles.editBeam_Start, 'String', num2str(Parameters.Beam.Ix));
set(handles.editDia_Start, 'String', num2str(Parameters.Dia.E));
set(handles.editBarrier_Start, 'String', num2str(Parameters.Barrier.fc));
set(handles.editSidewalk_Start, 'String', num2str(Parameters.Sidewalk.fc));
set(handles.editComposite_Start, 'String', num2str(Parameters.compAction.Ix));
 
% Load Parameter info into starting Parameter slots
if Parameters.Deck.Updating.fc.Update
    set(handles.editDeck_Min, 'String', num2str(Parameters.Deck.fc*Parameters.Deck.Updating.fc.Alpha(2)));
    set(handles.editDeck_Max, 'String', num2str(Parameters.Deck.fc*Parameters.Deck.Updating.fc.Alpha(3)));
end

if Parameters.Beam.Updating.Ix.Update 
    set(handles.editBeam_Min, 'String', num2str(Parameters.Beam.Ix*Parameters.Beam.Updating.Ix.Alpha(2)));
    set(handles.editBeam_Max, 'String', num2str(Parameters.Beam.Ix*Parameters.Beam.Updating.Ix.Alpha(3)));
end

if Parameters.Dia.Updating.E.Update    
    set(handles.editDia_Min, 'String', num2str(Parameters.Dia.E*Parameters.Dia.Updating.E.Alpha(2)));
    set(handles.editDia_Max, 'String', num2str(Parameters.Dia.E*Parameters.Dia.Updating.E.Alpha(3)));
end

if Parameters.Barrier.Updating.fc.Update
    set(handles.editBarrier_Min, 'String', num2str(Parameters.Barrier.fc*10^Parameters.Barrier.Updating.fc.Alpha(2)));
    set(handles.editBarrier_Max, 'String', num2str(Parameters.Barrier.fc*10^Parameters.Barrier.Updating.fc.Alpha(3)));
end

if Parameters.Sidewalk.Updating.fc.Update   
    set(handles.editSidewalk_Min, 'String', num2str(Parameters.Sidewalk.fc*10^Parameters.Sidewalk.Updating.fc.Alpha(2)));
    set(handles.editSidewalk_Max, 'String', num2str(Parameters.Sidewalk.fc*10^Parameters.Sidewalk.Updating.fc.Alpha(3)));
end

if Parameters.compAction.Updating.Ix.Update
    set(handles.editComposite_Min, 'String', num2str(Parameters.compAction.Ix*10^Parameters.compAction.Updating.Ix.Alpha(2)));
    set(handles.editComposite_Max, 'String', num2str(Parameters.compAction.Ix*10^Parameters.compAction.Updating.Ix.Alpha(3)));
end

%--------------------------------------------------------------------------

function pushbtnBoundaryConditions_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
Parameters = getappdata(0,'Parameters');
Node = getappdata(0,'Node');

% Get Field Values
[Parameters, Options] = GetFieldValues(Parameters, Options, handles);
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);

setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

if ~isfield(Options.handles, 'guiUserInputBearings_Variable_gui')
    setappdata(0,'Options',Options);
    UserInputBearings_Variable_gui();
else
    if strcmp(get(Options.handles.guiUserInputBearings_Variable_gui, 'visible'), 'on')
        set(Options.handles.guiUserInputBearings_Variable_gui, 'Visible', 'off');
    else
        set(Options.handles.guiUserInputBearings_Variable_gui, 'Visible', 'on');
    end    
end

% set correlation button on
set(handles.pushbtnStartCorrelation, 'Enable', 'on');

function pushbtnParameterSensitivity_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
Parameters = getappdata(0,'Parameters');
Node = getappdata(0,'Node');

% Get Field Values
[Parameters, Options] = GetFieldValues(Parameters, Options, handles);
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);

setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

if ~isfield(Options.handles, 'guiParameterSensitivity_gui')
    
    Options.handles.guiParameterSensitivity_gui = ParameterSensitivity_gui();
    uiwait(ParameterSensitivity_gui);

    Parameters = getappdata(0,'Parameters');
    
    % apply final values to fields
    % Get Field Values
    SetFieldValues(Parameters, handles)
else
    if strcmp(get(Options.handles.guiParameterSensitivity_gui, 'visible'), 'on')
        set(Options.handles.guiParameterSensitivity_gui, 'Visible', 'off');
    else
        set(Options.handles.guiParameterSensitivity_gui, 'Visible', 'on');
    end    
end

function pushbtnMassSensitivity_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');
Node = getappdata(0,'Node');

% Get Field Values
[Parameters, Options] = GetFieldValues(Parameters, Options, handles);
Parameters = SetModelParameters(Options.St7.uID, Parameters, Node);

setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

MassRedistributionCheck_gui();

%--------------------------------------------------------------------------

function checkboxUpdate_Deck_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editDeck_Max, 'enable', 'on');
    set(handles.editDeck_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editDeck_Max, 'enable', 'off');
    set(handles.editDeck_Min, 'enable', 'off');
end

function checkboxUpdate_Beam_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editBeam_Max, 'enable', 'on');
    set(handles.editBeam_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editBeam_Max, 'enable', 'off');
    set(handles.editBeam_Min, 'enable', 'off');
end

function checkboxUpdate_Dia_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editDia_Max, 'enable', 'on');
    set(handles.editDia_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editDia_Max, 'enable', 'off');
    set(handles.editDia_Min, 'enable', 'off');
end

function checkboxUpdate_Barrier_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editBarrier_Max, 'enable', 'on');
    set(handles.editBarrier_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editBarrier_Max, 'enable', 'off');
    set(handles.editBarrier_Min, 'enable', 'off');
end

function checkboxUpdate_Sidewalk_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editSidewalk_Max, 'enable', 'on');
    set(handles.editSidewalk_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editSidewalk_Max, 'enable', 'off');
    set(handles.editSidewalk_Min, 'enable', 'off');
end

function checkboxCompositeAction_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    % Set update options to active
    set(handles.editComposite_Max, 'enable', 'on');
    set(handles.editComposite_Min, 'enable', 'on');
else
    % Set update options to inactive
    set(handles.editComposite_Max, 'enable', 'off');
    set(handles.editComposite_Min, 'enable', 'off');
end

%--------------------------------------------------------------------------

function SingleModelslider_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
updateSingleModelCorrUI(handles,Parameters);

function sliderValue_2_Callback(hObject, eventdata, handles)

function sliderValue_3_Callback(hObject, eventdata, handles)

function editScale_Callback(hObject, eventdata, handles)

function checkCOMAC_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
updateSingleModelCorrUI(handles,Parameters);

function uitableFreq_CellSelectionCallback(hObject, eventdata, handles)
modeselect = eventdata.Indices;
setappdata(handles.guiSingleModelCorrelation,'modeselect',modeselect);
Parameters = getappdata(0,'Parameters');
updateSingleModelCorrUI(handles,Parameters);
% handles    structure with handles and user data (see GUIDATA)

%--------------------------------------------------------------------------

function editDeck_Start_Callback(hObject, eventdata, handles)

function editDeck_Min_Callback(hObject, eventdata, handles)

function editDeck_Max_Callback(hObject, eventdata, handles)

function editBeam_Start_Callback(hObject, eventdata, handles)

function editBeam_Max_Callback(hObject, eventdata, handles)

function editBeam_Min_Callback(hObject, eventdata, handles)

function editDia_Start_Callback(hObject, eventdata, handles)

function editDia_Min_Callback(hObject, eventdata, handles)

function editDia_Max_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------

function editNumAnaModes_Callback(hObject, eventdata, handles)

function popupfreqWeight_Callback(hObject, eventdata, handles)

function editfreqweightDelta_Callback(hObject, eventdata, handles)

function editTolFun_Callback(hObject, eventdata, handles)

function editTolX_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------

function editBarrier_Start_Callback(hObject, eventdata, handles)

function editBarrier_Min_Callback(hObject, eventdata, handles)

function editBarrier_Max_Callback(hObject, eventdata, handles)

function editSidewalk_Start_Callback(hObject, eventdata, handles)

function editSidewalk_Min_Callback(hObject, eventdata, handles)

function editSidewalk_Max_Callback(hObject, eventdata, handles)

function editComposite_Start_Callback(hObject, eventdata, handles)

function editComposite_Min_Callback(hObject, eventdata, handles)

function editComposite_Max_Callback(hObject, eventdata, handles)
