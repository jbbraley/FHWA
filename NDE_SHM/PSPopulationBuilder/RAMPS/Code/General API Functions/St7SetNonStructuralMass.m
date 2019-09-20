function varargout = NBIDataGui(varargin)
% NBIDATAGUI MATLAB code for NBIDataGui.fig
%      NBIDATAGUI, by itself, creates a new NBIDATAGUI or raises the existing
%      singleton*.
%
%      H = NBIDATAGUI returns the handle to a new NBIDATAGUI or the handle to
%      the existing singleton*.
%
%      NBIDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NBIDATAGUI.M with the given input arguments.
%
%      NBIDATAGUI('Property','Value',...) creates a new NBIDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NBIDataGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NBIDataGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NBIDataGui

% Last Modified by GUIDE v2.5 04-Nov-2013 16:15:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NBIDataGui_OpeningFcn, ...
                   'gui_OutputFcn',  @NBIDataGui_OutputFcn, ...
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


% --- Executes just before NBIDataGui is made visible.
function NBIDataGui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for UserInputBeamSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Set Up Inital Properties
set(handles.pushbtnGetNBI,'Enable','inactive');
set(handles.pushbtnGetNBI,'ForegroundColor',[.5 .5 .5]);
set(handles.popupStructureNumber,'Enable','inactive');
set(handles.popupStructureNumber,'ForegroundColor',[.5 .5 .5]);
set(handles.pushbtnClear,'Enable','inactive');
set(handles.pushbtnClear,'ForegroundColor',[.5 .5 .5]);
set(handles.pushbtnApplyNBI,'Enable','inactive');
set(handles.pushbtnApplyNBI,'ForegroundColor',[.5 .5 .5]);

% Load State List
tempcd = pwd;
cd('../');
load([pwd '\Tables\GUI\GuiInit.mat']);
cd(tempcd);

set(handles.popupState, 'String', ['Choose State...'; StateList]);

%% Set up table
% row names
RowName{1,1} = 'Year Built'; 
RowName{2,1} = 'Year Reconstructed';
RowName{4,1} = 'Deck Condition'; 
RowName{5,1} = 'Superstructure Condition'; 
RowName{6,1} = 'Posting Required?';
RowName{8,1} = 'Design Truck';
RowName{9,1} = 'Operating Rating Method'; 
RowName{10,1} = 'Oprerating Rating'; 
RowName{11,1} = 'Inventory Rating Method'; 
RowName{12,1} = 'Inventory Rating'; 
RowName{13,1} = 'Design Code';
RowName{15,1} = 'ADT';
RowName{16,1} = 'ADTT';
RowName{18,1} = 'Skew';
RowName{19,1} = 'Max Span Length'; 
RowName{20,1} = 'Total Length'; 
RowName{21,1} = 'Left Sidewalk Width'; 
RowName{22,1} = 'RightSidewalk Width'; 
RowName{23,1} = 'Roadway Width'; 
RowName{24,1} = 'Out to Out Width'; 
set(handles.uitableNBIData, 'RowName', RowName);

Data = cell(23,1);
set(handles.uitableNBIData, 'Data', Data);
set(handles.uitableNBIData, 'ColumnWidth', {143, 100});

Options.handles.guiNBIDataGui = handles.guiNBIDataGui;

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function varargout = NBIDataGui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% -------------- Selection Buttons ----------------------------------------
function popupStructureNumber_Callback(hObject, eventdata, handles)
% Set Buttons Active
set(handles.pushbtnApplyNBI,'Enable','inactive');
set(handles.pushbtnApplyNBI,'ForegroundColor',[.5 .5 .5]);
set(handles.pushbtnGetNBI,'Enable','on');
set(handles.pushbtnGetNBI,'ForegroundColor',[1 1 1]);

function popupState_Callback(hObject, eventdata, handles) %#ok<*INUSL>
h = waitbar(0.3, 'Loading NBI Data for State...');

% Set Buttons Active
set(handles.pushbtnGetNBI,'Enable','inactive');
set(handles.pushbtnGetNBI,'ForegroundColor',[.5 .5 .5]);
set(handles.pushbtnApplyNBI,'Enable','inactive');
set(handles.pushbtnApplyNBI,'ForegroundColor',[.5 .5 .5]);
set(handles.popupStructureNumber,'Enable','on');
set(handles.popupStructureNumber,'ForegroundColor',[0 0 0]);

stateInd = get(hObject,'Value');
stateList = get(hObject,'String');

% Build list of structures
temppath = pwd;
cd('../');
load([pwd '\Tables\State Data\' stateList{stateInd} '\NBIraw.mat']);
cd(temppath);

structList = NBI_data{1,2};
setappdata(0,'NBI_data',NBI_data);

waitbar(0.6, h);

set(handles.pushbtnClear,'Enable','on');
set(handles.pushbtnClear,'ForegroundColor',[1 1 1]);

set(handles.popupStructureNumber, 'String', ['Choose Structure Number...'; structList']);

close(h);

function pushbtnGetNBI_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
h = waitbar(0.3, 'Loading NBI Data for Structure...');

% Get state and structure number and load data
stateInd = get(handles.popupState,'Value');
stateList = get(handles.popupState,'String');

structureInd = get(handles.popupStructureNumber,'Value');
structureList = get(handles.popupStructureNumber,'String');

NBI_data = getappdata(0,'NBI_data');
waitbar(0.6, h);

% Set up buttons
set(handles.pushbtnApplyNBI,'Enable','on');
set(handles.pushbtnApplyNBI,'ForegroundColor',[1 1 1]);

% Get NBI Values and Parameters
NBI = GetNBIData(NBI_data, structureList(structureInd));
NBI = TranslateNBIData(NBI);

%% Below is code to populate table with NBI data
% Age
Data{1,1} = num2str(NBI.YearBuilt); 
Data{2,1} = NBI.Reconstructed;
Data{3,1} = '-------------------------------';

% Conditions and Posting
Data{4,1} = NBI.DeckCond{end}; 
Data{5,1} = NBI.SuperstructureCond{end}; 
Data{6,1} = NBI.PostingRequired;
Data{7,1} = '-------------------------------';

% Ratings and Design
Data{8,1} = NBI.DesignTruckName;
Data{9,1} = NBI.OpRatingMethod; 
Data{10,1} = num2str(NBI.OprRating); 
Data{11,1} = NBI.InvRatingMethod; 
Data{12,1} = num2str(NBI.InvRating); 
Data{13,1} = NBI.DesignCode;
Data{14,1} = '-------------------------------';

% ADT
Data{15,1} = num2str(NBI.ADT{end});
Data{16,1} = num2str(NBI.ADTT{end});
Data{17,1} = '-------------------------------';

% Geometry
Data{18,1} = num2str(NBI.Skew);
Data{19,1} = num2str(NBI.MaxSpanLength); 
Data{20,1} = num2str(NBI.TotalLength);
Data{21,1} = num2str(NBI.Sidewalk.Left); 
Data{22,1} = num2str(NBI.Sidewalk.Right); 
Data{23,1} = num2str(NBI.RoadWidth); 
Data{24,1} = num2str(NBI.Width); 

set(handles.uitableNBIData, 'Data', Data);

close(h);

setappdata(0,'NBI',NBI);

function pushbtnClear_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
NBI = getappdata(0,'NBI');
Parameters = getappdata(0,'Parameters');

Parameters.NBI = [];

Parameters.Geo = 'Adv';

Data{:,1} = [];

set(handles.uitableNBIData, 'Data', Data);

setappdata(0,'NBI',NBI);
setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

function pushbtnApplyNBI_Callback(hObject, eventdata, handles)
NBI = getappdata(0,'NBI');
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

Parameters.NBI = NBI;

% Place NBI fields for geometry in Parameters
Parameters.Length = NBI.MaxSpanLength; 
Parameters.Sidewalk.Left = NBI.Sidewalk.Left; 
Parameters.Sidewalk.Right = NBI.Sidewalk.Right; 
Parameters.RoadWidth = NBI.RoadWidth; 
Parameters.Width = NBI.Width; 

% Skew
Parameters.SkewNear = NBI.Skew;
Parameters.SkewFar = NBI.Skew;

Parameters.Geo = 'NBI';

% Get Structure Configuration
Parameters = GetStructureConfig(NBI, Parameters, [], Options);

set(Options.handles.guiNBIDataGui, 'Visible', 'off');

setappdata(0,'NBI',NBI);
setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

function guiNBIDataGui_CloseRequestFcn(hObject, eventdata, handles)
Options = getappdata(0,'Options');

Options.handles = rmfield(Options.handles,'guiNBIDataGui');
setappdata(0,'Options', Options);

delete(hObject);
