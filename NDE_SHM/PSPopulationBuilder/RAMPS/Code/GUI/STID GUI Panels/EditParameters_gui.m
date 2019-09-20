function varargout = EditParameters_gui(varargin)
% EDITPARAMETERS_GUI MATLAB code for EditParameters_gui.fig
%      EDITPARAMETERS_GUI, by itself, creates a new EDITPARAMETERS_GUI or raises the existing
%      singleton*.
%
%      H = EDITPARAMETERS_GUI returns the handle to a new EDITPARAMETERS_GUI or the handle to
%      the existing singleton*.
%
%      EDITPARAMETERS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITPARAMETERS_GUI.M with the given input arguments.
%
%      EDITPARAMETERS_GUI('Property','Value',...) creates a new EDITPARAMETERS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditParameters_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditParameters_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditParameters_gui

% Last Modified by GUIDE v2.5 13-Apr-2015 11:52:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditParameters_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @EditParameters_gui_OutputFcn, ...
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


function EditParameters_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for EditParameters_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Set handles in Options
Options = getappdata(0,'Options');
Options.handles.EditParameters_gui = handles;
setappdata(0,'Options',Options);

% Update tables
State = 'Init';
Parameters = UpdateParameterTable([], Options, Node, State);

function varargout = EditParameters_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function EditParameters_gui_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
% Remove handles from Options
Options = getappdata(0,'Options');
Options.handles = rmfield(Options.handles, 'EditParameters_gui');
setappdata(0,'Options',Options);

% Buttons -----------------------------------------------------------------

function pushbtnSensitivity_Callback(hObject, eventdata, handles)
% Get Parameter Values from Table
ParameterSensitivity_gui();

function pushbtnApply_Callback(hObject, eventdata, handles)

function pushbtnReset_Callback(hObject, eventdata, handles)

% Mass Div ----------------------------------------------------------------

function editYDiv_Callback(hObject, eventdata, handles)

function checkboxConstantTotalMass_Callback(hObject, eventdata, handles)
totalMass = sum(cell2mat(massData(:,2)));
if get(hObject, 'Value') % true - constant total mass
    Options.Correlation.ConstantTotalMass = 1;
    
    if totalMass ~= numZones
        Data(:,2) = mat2cell(ones(numZones,1), ones(numZones,1));
        set(handles.uitableMass, 'Data', Data);
        drawnow
    end
else
    Options.Correlation.ConstantTotalMass = 0;
end

setappdata(0, 'Options', Options);

% Util Functions-----------------------------------------------------------
function [Parameters, Options] = GetTableValues(Paramters, Options)
% Parameters


% Mass
Options.MassCorr.massMulti = get(handles.tableMass, 'Data');
numZones = size(Data,1);
