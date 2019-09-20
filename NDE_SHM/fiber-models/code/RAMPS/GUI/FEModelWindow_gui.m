function varargout = FEModelWindow_gui(varargin)
% FEMODELWINDOW_GUI MATLAB code for FEModelWindow_gui.fig
%      FEMODELWINDOW_GUI, by itself, creates a new FEMODELWINDOW_GUI or raises the existing
%      singleton*.
%
%      H = FEMODELWINDOW_GUI returns the handle to a new FEMODELWINDOW_GUI or the handle to
%      the existing singleton*.
%
%      FEMODELWINDOW_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEMODELWINDOW_GUI.M with the given input arguments.
%
%      FEMODELWINDOW_GUI('Property','Value',...) creates a new FEMODELWINDOW_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FEModelWindow_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FEModelWindow_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FEModelWindow_gui

% Last Modified by GUIDE v2.5 02-Feb-2015 16:49:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FEModelWindow_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @FEModelWindow_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before FEModelWindow_gui is made visible.
function FEModelWindow_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for FEModelWindow_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set Status for main figure so OutputFcn knows whats up
Status = 1;
setappdata(handles.guiFEModelWindow_gui, 'Status', Status);

function varargout = FEModelWindow_gui_OutputFcn(hObject, eventdata, handles) 
%get status for main fig
Status = getappdata(handles.guiFEModelWindow_gui, 'Status');

guiViewFEModelWindow(handles, Status);

varargout{1} = handles.output;

function guiFEModelWindow_gui_CloseRequestFcn(hObject, eventdata, handles)
% set Status for main figure so OutputFcn knows whats up
Status = 0;
guiViewFEModelWindow(handles, Status);

delete(hObject);

% Buttons -----------------------------------------------------------------

% Subfunctions ------------------------------------------------------------
