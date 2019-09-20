function varargout = SteelDiaSection_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SteelDiaSection_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SteelDiaSection_gui_OutputFcn, ...
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

function SteelDiaSection_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for SteelDiaSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Shapes
old = cd('../');
filepath = [pwd '\Tables\CShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\LShapes_Current.mat'];
load(filepath);
cd(old);

% Fill Shpaes Table
for i=1:length(CShapes)
    listCShapes{i} = CShapes(i).AISCManualLabel;
end
for i=1:length(LShapes)
    listLShapes{i} = LShapes(i).AISCManualLabel;
end
setappdata(0,'listLShapes',listLShapes);
setappdata(0,'listCShapes',listCShapes);

% Set handles in options
Options = getappdata(0,'Options');
Options.handles.SteelDiaSection_gui = handles;
setappdata(0,'Options', Options);

% Put temp Para file until new parameters are accepted
Parameters = getappdata(0,'Parameters');
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, Options);

function varargout = SteelDiaSection_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function SteelDiaSection_gui_CloseRequestFcn(hObject, eventdata, handles)

delete(hObject);

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');

if ~strcmp(Parameters.Dia.Assign, 'Auto')
    if strcmp(Parameters.Dia.Type, 'Beam')
        old = cd('../');
        filepath = [pwd '\Tables\CShapes_Current.mat'];
        load(filepath);
        cd(old);

        indDia = get(handles.listboxSection,'Value');

        Parameters.Dia.A = CShapes(indDia).A;
        Parameters.Dia.bf = CShapes(indDia).bf;
        Parameters.Dia.tf = CShapes(indDia).tf;
        Parameters.Dia.tw = CShapes(indDia).tw;
        Parameters.Dia.d = CShapes(indDia).d;
        Parameters.Dia.SectionName = CShapes(indDia).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.bf, Parameters.Dia.d, 0, Parameters.Dia.tf, Parameters.Dia.tw, 0];
    else   
        old = cd('../');
        filepath = [pwd '\Tables\LShapes_Current.mat'];
        load(filepath);
        cd(old);

        indDia = get(handles.listboxSection,'Value');

        Parameters.Dia.A = LShapes(indDia).A;
        Parameters.Dia.B = LShapes(indDia).B;
        Parameters.Dia.d = LShapes(indDia).d;
        Parameters.Dia.t = LShapes(indDia).t;
        Parameters.Dia.SectionName = LShapes(indDia).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.B, Parameters.Dia.d, 0, Parameters.Dia.t, Parameters.Dia.t, 0];
    end
end

% Get number of diaphragm rows
data = get(handles.tableDiaRows, 'Data');
Parameters.NumDia = str2double(data(:,2));


Parameters = GetStructureConfig([], Parameters, [], [], []);

setappdata(0,'Parameters',Parameters);

function pushbtnCancel_Callback(hObject, eventdata, handles)
SteelDiaSection_CloseRequestFcn(handles.SteelDiaSection_gui, eventdata, handles)

function listboxSection_Callback(hObject, eventdata, handles)

function listboxSection_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobtnChevron_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Type = 'Chevron';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function radiobtnCross_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Type = 'Cross';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function radiobtnBeam_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Type = 'Beam';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function checkboxAutoAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'Para_temp');
if get(hObject, 'Value')    
    Parameters.Dia.Assign = 'Auto';
else
    Parameters.Dia.Assign = 'Manual';
end
setappdata(0, 'Para_temp', Parameters);

UpdateDiaTables(Parameters, []);

function radiobtnStaggered_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Config = 'Stagger';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function radiobtnNormal_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Config = 'Normal';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function radiobtnParallel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');
Parameters.Dia.Config = 'Parallel';
setappdata(0,'Para_temp',Parameters);

UpdateDiaTables(Parameters, []);

function tableDiaRows_CellEditCallback(hObject, eventdata, handles)
Parameters = getappdata(0,'Para_temp');

% Get number of diaphragm rows
data = get(handles.tableDiaRows, 'Data');
Parameters.NumDia = data{1,2};

setappdata(0,'Para_temp',Parameters);
