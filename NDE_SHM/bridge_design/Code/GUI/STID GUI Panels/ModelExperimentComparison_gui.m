function varargout = ModelExperimentComparison_gui(varargin)
% MODELEXPERIMENTCOMPARISON_GUI MATLAB code for ModelExperimentComparison_gui.fig
%      MODELEXPERIMENTCOMPARISON_GUI, by itself, creates a new MODELEXPERIMENTCOMPARISON_GUI or raises the existing
%      singleton*.
%
%      H = MODELEXPERIMENTCOMPARISON_GUI returns the handle to a new MODELEXPERIMENTCOMPARISON_GUI or the handle to
%      the existing singleton*.
%
%      MODELEXPERIMENTCOMPARISON_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODELEXPERIMENTCOMPARISON_GUI.M with the given input arguments.
%
%      MODELEXPERIMENTCOMPARISON_GUI('Property','Value',...) creates a new MODELEXPERIMENTCOMPARISON_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ModelExperimentComparison_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ModelExperimentComparison_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ModelExperimentComparison_gui

% Last Modified by GUIDE v2.5 13-Mar-2015 16:16:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ModelExperimentComparison_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ModelExperimentComparison_gui_OutputFcn, ...
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


% --- Executes just before ModelExperimentComparison_gui is made visible.
function ModelExperimentComparison_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ModelExperimentComparison_gui (see VARARGIN)

% Choose default command line output for ModelExperimentComparison_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get data from root
Options = getappdata(0,'Options');

% set number of analytical modes
set(handles.editNumAnaModes, 'String', num2str(Options.Analysis.NumModes));

% mode shape scales
set(handles.editExpScale, 'String', num2str(Options.GUI.expScale));
set(handles.editAnaScale, 'String', num2str(Options.GUI.anaScale));

% turn rotation of figures on
rotate3d(handles.axesAnaModeShape,'on');
rotate3d(handles.axesExpModeShape,'on');

% Set app data
Options.handles.ModelExperimentComparison_gui = handles;

setappdata(0, 'Options', Options);

% Update figures if data available
if Options.FileOpen.TestData
    testData = getappdata(0,'testData');
    
    % Get MAC and COMAC Values
    testData.MAC = GetMACValue(testData.U, testData.U);
    testData.COMAC = GetCOMACValue(testData.U, testData.U);
    
    % set data to root
    setappdata(0,'testData', testData);
    
    plotType = 'Exp';
    PlotModeShapes(plotType);
    PlotMAC(handles,plotType);
    UpdateNatFreqTables(handles);
end
if Options.FileOpen.Node && Options.FileOpen.St7Model
    meshData = getappdata(0,'meshData');
    testData = getappdata(0,'testData');
    
    % get freqs and mode shapes
    meshData = LoadNaturalFrequencyData(Options, meshData, meshData.nodeID); % calls function to run solver, get results, and save data to meshData
    
    plotType = 'Ana';
    PlotModeShapes(plotType);
    
    if ~isempty(testData)
        meshData = NaturalFrequencyComparison(Options, meshData, testData);
        PlotMAC(handles,plotType);
    end

    UpdateNatFreqTables(handles);
end

function varargout = ModelExperimentComparison_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function ModelExperimentComparison_gui_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% Edit, buttons, and Selection Boxes --------------------------------------

function pushbtnRunAnalysis_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');

% Get number of analytical modes
Options.Analysis.NumModes = str2double(get(handles.editNumAnaModes, 'String'));

% Check if test or meta data file is already loaded
if Options.FileOpen.Node && Options.FileOpen.St7Model
    meshData = getappdata(0,'meshData');
    testData = getappdata(0,'testData');
    
    % get freqs and mode shapes
    meshData = LoadNaturalFrequencyData(Options, meshData, meshData.nodeID); % calls function to run solver, get results, and save data to meshData
    
    plotType = 'Ana';
    PlotModeShapes(plotType);
    
    if ~isempty(testData)
        meshData = NaturalFrequencyComparison(Options, meshData, testData);
        PlotMAC(handles,plotType);
    end

    UpdateNatFreqTables(handles);
end
if Options.FileOpen.TestData
    plotType = 'Exp';
    PlotModeShapes(plotType);
end

function editNumAnaModes_Callback(hObject, eventdata, handles)

function editAnaScale_Callback(hObject, eventdata, handles)
% Get data from root
Options = getappdata(0,'Options');

% Get current scale data
Options.GUI.anaScale = str2num(get(handles.editAnaScale, 'String'));

% Set data to root
setappdata(0,'Options',Options);

% plot ana shape
plotType = 'Ana';
PlotModeShapes(plotType);

function editExpScale_Callback(hObject, eventdata, handles)
% Get data from root
Options = getappdata(0,'Options');

% Get current scale data
Options.GUI.expScale = str2num(get(handles.editExpScale, 'String'));

% Set data to root
setappdata(0,'Options',Options);

plotType = 'Exp';
PlotModeShapes(plotType);

% Tables ------------------------------------------------------------------

function uitableAnaExpFreq_CellSelectionCallback(hObject, eventdata, handles)
TableSelection(hObject, eventdata, handles)

function uitableNatFreqComparison_CellSelectionCallback(hObject, eventdata, handles)
TableSelection(hObject, eventdata, handles)

function TableSelection(hObject, eventdata, handles)
% get data from root
Options = getappdata(0,'Options');
meshData = getappdata(0,'meshData');

% get selected modes
if strcmp(get(hObject, 'Tag'), 'uitableAnaExpFreq')
    anaCol = 1;
    expCol = 2;
    checkCol = 3;
    anaRow = 0;
else
    anaCol = 3;
    expCol = 2;
    checkCol = 0;
    anaRow = meshData.pairedModes(:,2) - [1:length(meshData.pairedModes)]';
end

if any(eventdata.Indices(:,2) == anaCol) % ana column selection
    row = eventdata.Indices(:,find(eventdata.Indices(:,2) == anaCol,1,'first')); % get first mode in ana column in case of multiselect
    Options.GUI.anaModeNum = row-anaRow(row) ;
    % gset data to root
    setappdata(0,'Options',Options);
    
    plotType = 'Ana';
    % Plot
    PlotModeShapes(plotType);
elseif any(eventdata.Indices(:,2) == expCol) % exp column selection
    Options.GUI.expModeNum = eventdata.Indices(:,find(eventdata.Indices(:,2) == expCol,1,'first'));
    % gset data to root
    setappdata(0,'Options',Options);
    
    plotType = 'Exp';
    % Plot
    PlotModeShapes(plotType);
    plotType = 'Ana';
    % Plot
    PlotModeShapes(plotType);
end    

function uitableAnaExpFreq_CellEditCallback(hObject, eventdata, handles)
% get data from root
Options = getappdata(0,'Options');

data = get(hObject,'Data');
Options.Correlation.expModes = find(cell2mat(data(:,3)));
setappdata(0,'Options',Options);

meshData = NaturalFrequencyComparison(Options, [], []);

if ~isempty(meshData)
    plotType = 'Ana';
    PlotMAC(handles, plotType);
end
