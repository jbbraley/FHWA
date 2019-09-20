function varargout = ChooseModelType_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseModelType_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseModelType_gui_OutputFcn, ...
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

function ChooseModelType_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = ChooseModelType_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function RAMPS_pb_Callback(hObject, eventdata, handles)
SteelGirderRAMPS_gui();
delete(handles.guiChooseModelType);

function Manual_pb_Callback(hObject, eventdata, handles)
SteelGirderManual_gui();
delete(handles.guiChooseModelType);
