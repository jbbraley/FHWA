% 10/2/2014 (NPR): Set all elements in GUI to "normalized" to allow for
% resizing.

function varargout = UserInputDiaSection(varargin)
% Last Modified by GUIDE v2.5 02-Oct-2014 13:37:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputDiaSection_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputDiaSection_OutputFcn, ...
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


% --- Executes just before UserInputDiaSection is made visible.
function UserInputDiaSection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInputDiaSection (see VARARGIN)

% Choose default command line output for UserInputBeamSection_gui
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
    
    % Dia Type
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
    
    PShandles = [handles.BeamPic handles.text5 handles.text6, handles.editb handles.editD];
    
    switch Parameters.structureType
        case 'Steel'
            set(handles.checkboxDiaAssign, 'Value', 0);
            Parameters.Dia.Assign = 'Manual';

            set(handles.listboxDiaSection,'String',listCShapes);

            % Diaphragm radio buttons
            set(handles.radiobtnDiaType_Girder,'value',1);
            set(handles.radiobtnDiaType_Girder,'Enable','inactive');
            set(handles.radiobtnDiaType_Cross,'value',0);
            set(handles.radiobtnDiaType_Chevron,'value',0);
            
            set(PShandles,'visible','off');

            Parameters.Dia.Type = 'Beam';
            
            set(handles.radiobtnDiaConfig_Parallel,'value',1);
            set(handles.radiobtnDiaConfig_Parallel,'Enable','inactive');
            set(handles.radiobtnDiaConfig_Normal,'value',0);
    
        case 'Prestressed'
            set(handles.checkboxDiaAssign, 'Value', 0);
            Parameters.Dia.Assign = 'Manual';

            % Show Beam Picture
            axes(handles.BeamPic);
            old = cd('../');
            imshow([pwd '\Img\RecBeam.jpg']);
            cd(old);      
            
            set(handles.listboxDiaSection,'visible','off');

            % Diaphragm radio buttons
            set(handles.radiobtnDiaType_Girder,'value',0);
            set(handles.radiobtnDiaType_Cross,'value',0);
            set(handles.radiobtnDiaType_Chevron,'value',0);
            set(handles.radiobtnDiaType_Concrete,'value',1);
            set(handles.radiobtnDiaType_Concrete,'Enable','inactive');
            set(handles.radiobtnDiaConfig_Normal,'value',1);
            set(handles.radiobtnDiaConfig_Normal,'enable','inactive');
            set(handles.radiobtnDiaConfig_Parallel,'enable','off');
            Parameters.Dia.Type = 'Concrete';
    end
    
     % Diaphragm radio buttons
    set(handles.radiobtnDiaConfig_Stagger,'value',0);
    
    Parameters.Dia.Config = 'Parallel';
    
    % Dia spacing
    data = get(handles.uitableNumDia, 'Data'); 
    Parameters.NumDia = ceil(Parameters.Length/300)-1;
    Parameters.Dia.Spacing = Parameters.Length./(Parameters.NumDia+1);
    for i = 1:Parameters.Spans
        data{i,2} = Parameters.NumDia(i);
    end
    set(handles.uitableNumDia, 'Data', data);
end

Options.handles.guiUserInputDiaSection = handles.guiUserInputDiaSection;

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function varargout = UserInputDiaSection_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function listboxDiaSection_Callback(hObject, eventdata, handles)

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

if get(handles.radiobtnDiaType_Concrete,'Value')
    Parameters.Dia.Type = 'Concrete';
    Parameters.Dia.b = str2double(get(handles.editb,'string'));
    Parameters.Dia.d = str2double(get(handles.editD,'string'));
    Parameters.Dia.A = Parameters.Dia.b*Parameters.Dia.d;
    Parameters.Dia.SectionName = ['Rec' num2str(Parameters.Dia.b) 'X' num2str(Parameters.Dia.d)];
    Parameters.Dia.Section = [Parameters.Dia.d Parameters.Dia.b 0 0 0 0];

elseif get(handles.radiobtnDiaType_Girder,'Value')
    Parameters.Dia.Type = 'Beam';
    
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
else       
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

% Dia spacing
data = get(handles.uitableNumDia, 'Data');
Parameters.NumDia = cell2mat(data(:,2));
Parameters.Dia.Spacing = Parameters.Length./(Parameters.NumDia+1);

if get(handles.checkboxDiaAssign, 'Value')
    Parameters.Dia.Assign = 'Auto';
else
    Parameters.Dia.Assign = 'Manual';
end

setappdata(0,'Parameters',Parameters);

set(handles.guiUserInputDiaSection, 'Visible', 'off');

function pushbtnCancel_Callback(hObject, eventdata, handles)
guiUserInputDiaSection_CloseRequestFcn(handles.guiUserInputDiaSection, eventdata, handles)

function guiUserInputDiaSection_CloseRequestFcn(hObject, eventdata, handles)
Options = getappdata(0,'Options');
Options.handles = rmfield(Options.handles,'guiUserInputDiaSection');
setappdata(0,'Options',Options);

delete(hObject);

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

% --------------------- Type --------------------------------------------
function checkboxDiaAssign_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')    
    % Put LShapes list in listbox
    listLShapes = getappdata(0,'listLShapes');
    set(handles.listboxDiaSection,'String',listLShapes);
    
    % Set Radio Button
    set(handles.radiobtnDiaType_Girder,'value',0);
    set(handles.radiobtnDiaType_Girder,'Enable','inactive');
    set(handles.radiobtnDiaType_Cross,'value',1);
    set(handles.radiobtnDiaType_Cross,'Enable','inactive');
    set(handles.radiobtnDiaType_Chevron,'value',0);
    set(handles.radiobtnDiaType_Chevron,'Enable','inactive');
else
    set(handles.radiobtnDiaType_Girder,'Enable','on');
    set(handles.radiobtnDiaType_Cross,'Enable','on');
    set(handles.radiobtnDiaType_Chevron,'Enable','on');
end

function radiobtnDiaType_Chevron_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',0);
set(handles.radiobtnDiaType_Girder,'Enable','on');
set(handles.radiobtnDiaType_Cross,'value',0);
set(handles.radiobtnDiaType_Cross,'Enable','on');
set(handles.radiobtnDiaType_Concrete,'value',0);
set(handles.radiobtnDiaType_Concrete,'Enable','on');
set(handles.radiobtnDiaType_Chevron,'value',1);
set(handles.radiobtnDiaType_Chevron,'Enable','inactive');

PShandles = [findall(handles.BeamPic)' handles.text5 handles.text6, handles.editb handles.editD];
set(handles.listboxDiaSection,'visible','on');
set(PShandles,'Visible','off');

listLShapes = getappdata(0,'listLShapes');
set(handles.listboxDiaSection,'String',listLShapes);

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Chevron';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaType_Cross_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',0);
set(handles.radiobtnDiaType_Girder,'Enable','on');
set(handles.radiobtnDiaType_Cross,'value',1);
set(handles.radiobtnDiaType_Cross,'Enable','inactive');
set(handles.radiobtnDiaType_Chevron,'value',0);
set(handles.radiobtnDiaType_Chevron,'Enable','on');
set(handles.radiobtnDiaType_Concrete,'value',0);
set(handles.radiobtnDiaType_Concrete,'Enable','on');

listLShapes = getappdata(0,'listLShapes');
set(handles.listboxDiaSection,'String',listLShapes);

PShandles = [findall(handles.BeamPic)' handles.text5 handles.text6, handles.editb handles.editD];
set(handles.listboxDiaSection,'visible','on');
set(PShandles,'visible','off');

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Cross';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaType_Girder_Callback(hObject, eventdata, handles)
set(handles.radiobtnDiaType_Girder,'value',1);
set(handles.radiobtnDiaType_Girder,'Enable','inactive');
set(handles.radiobtnDiaType_Cross,'value',0);
set(handles.radiobtnDiaType_Cross,'Enable','on');
set(handles.radiobtnDiaType_Chevron,'value',0);
set(handles.radiobtnDiaType_Chevron,'Enable','on');
set(handles.radiobtnDiaType_Concrete,'value',0);
set(handles.radiobtnDiaType_Concrete,'Enable','on');

listCShapes = getappdata(0,'listCShapes');
set(handles.listboxDiaSection,'String',listCShapes);

PShandles = [findall(handles.BeamPic)' handles.text5 handles.text6, handles.editb handles.editD];
set(handles.listboxDiaSection,'visible','on');
set(PShandles,'visible','off');

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Beam';
setappdata(0,'Parameters',Parameters);

function radiobtnDiaType_Concrete_Callback(hObject, eventdata, handles)
PShandles = [allchild(handles.BeamPic)' handles.text5 handles.text6, handles.editb handles.editD];

set(handles.radiobtnDiaType_Girder,'value',0);
set(handles.radiobtnDiaType_Girder,'Enable','on');
set(handles.radiobtnDiaType_Cross,'value',0);
set(handles.radiobtnDiaType_Cross,'Enable','on');
set(handles.radiobtnDiaType_Chevron,'value',0);
set(handles.radiobtnDiaType_Chevron,'Enable','on');
set(handles.radiobtnDiaType_Concrete,'value',1);
set(handles.radiobtnDiaType_Concrete,'Enable','inactive');

set(handles.listboxDiaSection,'visible','off');
set(PShandles,'visible','on');

Parameters = getappdata(0,'Parameters');
Parameters.Dia.Type = 'Concrete';
setappdata(0,'Parameters',Parameters);



function editb_Callback(hObject, eventdata, handles)
% hObject    handle to editb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editb as text
%        str2double(get(hObject,'String')) returns contents of editb as a double


% --- Executes during object creation, after setting all properties.
function editb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editD_Callback(hObject, eventdata, handles)
% hObject    handle to editD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editD as text
%        str2double(get(hObject,'String')) returns contents of editD as a double


% --- Executes during object creation, after setting all properties.
function editD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbtnAssign_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbtnAssign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbtnCancel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbtnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
