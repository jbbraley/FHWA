function varargout = ChooseSteelDiaSection_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseSteelDiaSection_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseSteelDiaSection_gui_OutputFcn, ...
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

function ChooseSteelDiaSection_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ChooseSteelDiaSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

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

% Dia Rows Table 
data = cell(Parameters.Spans,2);
for i=1:Parameters.Spans
    data{i,1} = ['Span ' num2str(i) ':'];
end

set(handles.uitableNumDia, 'Data', data);
set(handles.uitableNumDia, 'Units', 'pixels');
set(handles.uitableNumDia, 'ColumnWidth', {60, 70});
set(handles.uitableNumDia, 'ColumnEditable', [false, true]);

% Set Diaphragm Section if Chosen Already by AASHTO Design
if strcmp(Parameters.Geo, 'NBI') && isfield(Parameters.Dia, 'Type')
    % Num Dia
    % Dia spacing
    data = get(handles.uitableNumDia, 'Data'); 
    Parameters.NumDia = ceil(Parameters.Length/300)-1;
    Parameters.Dia.Spacing = Parameters.Length./(Parameters.NumDia+1);
    for i = 1:Parameters.Spans
        data{i,2} = Parameters.NumDia(i);
    end
    set(handles.uitableNumDia, 'Data', data);
    
    % Dia Config
    if strcmp(Parameters.Dia.Config,'Parallel')
        set(handles.radiobtnDiaConfig_Parallel,'value',1);
        set(handles.radiobtnDiaConfig_Parallel,'Enable','inactive');
        set(handles.radiobtnDiaConfig_Normal,'value',0);
        set(handles.radiobtnDiaConfig_Stagger,'value',0);
    elseif strcmp(Parameters.Dia.Config,'Normal')
        set(handles.radiobtnDiaConfig_Parallel,'value',0);
        set(handles.radiobtnDiaConfig_Normal,'value',1);
        set(handles.radiobtnDiaConfig_Normal,'Enable','inactive');
        set(handles.radiobtnDiaConfig_Stagger,'value',0);
    else
        set(handles.radiobtnDiaConfig_Parallel,'value',0);
        set(handles.radiobtnDiaConfig_Normal,'value',0);
        set(handles.radiobtnDiaConfig_Stagger,'value',0);
        set(handles.radiobtnDiaConfig_Stagger,'Enable','inactive');
    end
    
    % Default = Automatically assign
    set(handles.checkboxDiaAssign, 'Value', 1);
    Parameters.Dia.Assign = 'Auto';
    
    if strcmp(Parameters.Dia.Type,'Beam')
        % Put CShapes list in listbox
        set(handles.listboxDiaSection,'String',listCShapes);
        
        % Find chosen section
        listSection = get(handles.listboxDiaSection,'string');
        indSection = find(not(cellfun('isempty', strfind(listSection, Parameters.Dia.SectionName))));
        set(handles.listboxDiaSection,'value',indSection);
        
        % Set radio button
        set(handles.radiobtnDiaType_Girder,'value',1);
        set(handles.radiobtnDiaType_Girder,'Enable','inactive');
        set(handles.radiobtnDiaType_Cross,'value',0);
        set(handles.radiobtnDiaType_Cross,'Enable','inactive');
        set(handles.radiobtnDiaType_Chevron,'value',0);
        set(handles.radiobtnDiaType_Chevron,'Enable','inactive');
    else
        % Put LShapes list in listbox
        set(handles.listboxDiaSection,'String',listLShapes);
        
        % Find chosen section
        listSection = get(handles.listboxDiaSection,'string');
        indSection = find(not(cellfun('isempty', strfind(listSection, Parameters.Dia.SectionName))));
        set(handles.listboxDiaSection,'value',indSection);
        
        % Set Radio Button
        set(handles.radiobtnDiaType_Girder,'value',0);
        set(handles.radiobtnDiaType_Girder,'Enable','inactive');
        set(handles.radiobtnDiaType_Cross,'value',1);
        set(handles.radiobtnDiaType_Cross,'Enable','inactive');
        set(handles.radiobtnDiaType_Chevron,'value',0);
        set(handles.radiobtnDiaType_Chevron,'Enable','inactive');
    end
else    
    
    % Default = Automatically assign cross-bracing
    set(handles.checkboxDiaAssign, 'Value', 1);
    Parameters.Dia.Assign = 'Auto';
    set(handles.listboxDiaSection,'String','Auto Assign Dia Section');
    set(handles.radiobtnDiaType_Cross,'value',1);

    % De-select other Diaphragm radio buttons
    set(handles.radiobtnDiaType_Girder,'value',0);
    set(handles.radiobtnDiaType_Chevron,'value',0);

    % Diaphragm Config Radio Buttons, Default = Normal to girder
    set(handles.radiobtnDiaConfig_Normal,'value',1);
    set(handles.radiobtnDiaConfig_Stagger,'value',0);
    if Parameters.SkewNear > 0 || Parameters.SkewFar > 0
       set(handles.radiobtnDiaConfig_Parallel,'value',1);
       set(handles.radiobtnDiaConfig_Normal,'value',0);
    else
       set(handles.radiobtnDiaConfig_Parallel,'Enable','inactive');
    end
    
    % Dia spacing
    data = get(handles.uitableNumDia, 'Data'); 
    Parameters.NumDia = ceil(Parameters.Length/300)-1;
    Parameters.Dia.Spacing = Parameters.Length./(Parameters.NumDia+1);
    for i = 1:Parameters.Spans
        data{i,2} = Parameters.NumDia(i);
    end
    set(handles.uitableNumDia, 'Data', data);
end

Options.handles.guiChooseSteelDiaSection = handles.guiChooseSteelDiaSection;

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function guiChooseSteelDiaSection_gui_CloseRequestFcn(hObject, eventdata, handles)
Options = getappdata(0,'Options');
Options.handles = rmfield(Options.handles,'guiChooseSteelDiaSection');
setappdata(0,'Options',Options);

delete(hObject);

function varargout = ChooseSteelDiaSection_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function listboxDiaSection_Callback(hObject, eventdata, handles)

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Save temprary parameters up to this point
P_Temp2 = Parameters;
setappdata(0, 'P_Temp2', P_Temp2);

% Dia Config
if get(handles.radiobtnDiaConfig_Parallel,'value') == 1
    Parameters.Dia.Config = 'Parallel';
elseif get(handles.radiobtnDiaConfig_Normal,'value') == 1
    Parameters.Dia.Config = 'Normal';
else
    Parameters.Dia.Config = 'Staggered';
end

% Dia Type
if get(handles.checkboxDiaAssign, 'Value')
    Parameters.Dia.Assign = 'Auto';
else
    Parameters.Dia.Assign = 'Manual';
    if strcmp(Parameters.Dia.Type, 'Beam')
        old = cd('../');
        filepath = [pwd '\Tables\CShapes_Current.mat'];
        load(filepath);
        cd(old);
        indDia = get(handles.listboxDiaSection,'Value');
        Parameters.Dia.A = CShapes(indDia).A;
        Parameters.Dia.bf = CShapes(indDia).bf;
        Parameters.Dia.tf = CShapes(indDia).tf;
        Parameters.Dia.tw = CShapes(indDia).tw;
        Parameters.Dia.d = CShapes(indDia).d;
        Parameters.Dia.SectionName = CShapes(indDia).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.bf, Parameters.Dia.d, 0, Parameters.Dia.tf, Parameters.Dia.tw, 0];
    elseif get(handles.radiobtnDiaType_Cross, 'Value')       
        old = cd('../');
        filepath = [pwd '\Tables\LShapes_Current.mat'];
        load(filepath);
        cd(old);
        indDia = get(handles.listboxDiaSection,'Value');
        Parameters.Dia.A = LShapes(indDia).A;
        Parameters.Dia.B = LShapes(indDia).B;
        Parameters.Dia.d = LShapes(indDia).d;
        Parameters.Dia.t = LShapes(indDia).t;
        Parameters.Dia.SectionName = LShapes(indDia).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.B, Parameters.Dia.d, 0, Parameters.Dia.t, Parameters.Dia.t, 0];
    end
end

% Dia spacing
data = get(handles.uitableNumDia, 'Data');
Parameters.NumDia = cell2mat(data(:,2));
Parameters.Dia.Spacing = Parameters.Length./(Parameters.NumDia+1);

setappdata(0,'Parameters',Parameters);

set(handles.guiChooseSteelDiaSection, 'Visible', 'off');

function pushbtnCancel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_Temp1');
setappdata(0, 'Parameters', Parameters);
if isappdata(0, 'P_Temp2')
    rmappdata(0, 'P_Temp2');
end
guiChooseSteelDiaSection_gui_CloseRequestFcn(handles.guiChooseSteelDiaSection, eventdata, handles)

function radiobtnDiaConfig_Stagger_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

switch Parameters.structureType
    case 'Prestressed'
        
    otherwise
        set(handles.radiobtnDiaConfig_Parallel,'value',0);
        set(handles.radiobtnDiaConfig_Parallel,'Enable','on');
end

set(handles.radiobtnDiaConfig_Normal,'value',0);
set(handles.radiobtnDiaConfig_Normal,'Enable','on');
set(handles.radiobtnDiaConfig_Stagger,'value',1);
set(handles.radiobtnDiaConfig_Stagger,'Enable','inactive');

Parameters.Dia.Config = 'Stagger';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaConfig_Normal_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

switch Parameters.structureType
    case 'Prestressed'
        
    otherwise
        set(handles.radiobtnDiaConfig_Parallel,'value',0);
        set(handles.radiobtnDiaConfig_Parallel,'Enable','on');
end

set(handles.radiobtnDiaConfig_Normal,'value',1);
set(handles.radiobtnDiaConfig_Normal,'Enable','inactive');
set(handles.radiobtnDiaConfig_Stagger,'value',0);
set(handles.radiobtnDiaConfig_Stagger,'Enable','on');


Parameters.Dia.Config = 'Normal';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaConfig_Parallel_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaConfig_Parallel,'value',1);
set(handles.radiobtnDiaConfig_Parallel,'Enable','inactive');
set(handles.radiobtnDiaConfig_Normal,'value',0);
set(handles.radiobtnDiaConfig_Normal,'Enable','on');
set(handles.radiobtnDiaConfig_Stagger,'value',0);
set(handles.radiobtnDiaConfig_Stagger,'Enable','on');

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Config = 'Parallel';
setappdata(0,'Parameters',Parameters);

function checkboxDiaAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'Parameters');
if get(hObject, 'Value')    
    Parameters.Dia.Assign = 'Auto';
    % Set Radio Buttons
    if Parameters.SkewNear < 20
        set(handles.radiobtnDiaConfig_Parallel, 'value',1);
        set(handles.radiobtnDiaConfig_Normal, 'value',0);
        set(handles.radiobtnDiaConfig_Stagger, 'value',0);
    else
        set(handles.radiobtnDiaConfig_Normal, 'value',1);
        set(handles.radiobtnDiaConfig_Stagger, 'value',0);
        set(handles.radiobtnDiaConfig_Parallel, 'value',0);
    end

    set(handles.radiobtnDiaType_Girder,'Enable','inactive');
    set(handles.radiobtnDiaType_Cross,'Enable','inactive');
    set(handles.radiobtnDiaType_Chevron,'Enable','inactive');
else
    Parameters.Dia.Assign = 'Manual';
    set(handles.radiobtnDiaType_Girder,'Enable','on');
    set(handles.radiobtnDiaType_Cross,'Enable','on');
    set(handles.radiobtnDiaType_Chevron,'Enable','on');
end
setappdata(0, 'Parameters', Parameters);

function radiobtnDiaType_Chevron_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',0);
set(handles.radiobtnDiaType_Cross,'value',0);
set(handles.radiobtnDiaType_Chevron,'value',1);
set(handles.checkboxDiaAssign, 'value', 0);

listLShapes = getappdata(0,'listLShapes');
set(handles.listboxDiaSection,'String',listLShapes);

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Chevron';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaType_Cross_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',0);
set(handles.radiobtnDiaType_Cross,'value',1);
set(handles.radiobtnDiaType_Chevron,'value',0);

listLShapes = getappdata(0,'listLShapes');
set(handles.listboxDiaSection,'String',listLShapes);

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Cross';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaType_Girder_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',1);
set(handles.radiobtnDiaType_Cross,'value',0);
set(handles.radiobtnDiaType_Chevron,'value',0);
set(handles.checkboxDiaAssign, 'value', 0);

listCShapes = getappdata(0,'listCShapes');
set(handles.listboxDiaSection,'String',listCShapes);

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Beam';
setappdata(0,'Parameters',Parameters);

function pushbtnAssign_CreateFcn(hObject, eventdata, handles)

function pushbtnCancel_CreateFcn(hObject, eventdata, handles)
