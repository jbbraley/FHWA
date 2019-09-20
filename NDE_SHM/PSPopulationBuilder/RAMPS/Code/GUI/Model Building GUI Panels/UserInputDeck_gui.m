function varargout = UserInputDeck_gui(varargin)
% Last Modified by GUIDE v2.5 13-Mar-2015 16:16:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputDeck_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputDeck_gui_OutputFcn, ...
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

function UserInputDeck_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for UserInputBeamSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Set handles
Options.handles.UserInputDeck_gui = handles;

State = 'Init';
UpdateGeometryTables(Parameters, Options, State);
if ~strcmp(Parameters.structureType, 'None')
    State = 'Update';
    UpdateGeometryTables(Parameters, Options, State);
end

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

function UserInputDeck_gui_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function varargout = UserInputDeck_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

type = get(handles.popupmenuType,'value');
data = get(handles.tableGeometry,'Data');
lengths = get(handles.tableLengths,'Data');

Parameters.Length = cell2mat(lengths(:,2));
Parameters.RoadWidth = data{1,2};
Parameters.SkewNear = data{2,2};
Parameters.SkewFar = data{3,2};
Parameters.Deck.t = data{4,2};
Parameters.Sidewalk.Height = data{5,2};
Parameters.Sidewalk.Left = data{6,2};
Parameters.Sidewalk.Right = data{7,2};
Parameters.Barrier.Height = data{8,2};
Parameters.Barrier.Width = data{9,2};

Parameters.Deck.WearingSurface = data{10,2};
Parameters.Deck.Offset = data{11,2};

Parameters.Deck.fc = data{12,2};

Parameters.Barrier.fc = data{14,2};
Parameters.Sidewalk.fc = data{15,2};

switch type
    case 1
        Parameters.Beam.Fy = data{13,2};
        Parameters.Beam.fc = 'NA';
        Parameters.Dia.fc = 'NA';
        Parameters.Beam.PSSteel.Fu = 'NA';
        Parameters.structureType = 'Steel';
    case 2
        Parameters.Beam.Fy = 'NA';
        Parameters.Beam.fc = data{13,2};
        Parameters.Dia.fc = data{16,2};
        Parameters.Beam.PSSteel.Fu = data{17,2}*1000;
        Parameters.structureType = 'Prestressed';
    otherwise
end

% Error Screening
if ~isempty(find(cellfun(@isempty,data(:,2)))) || ~isempty(find(cellfun(@isempty,lengths(:,2))))
    msgbox('Please assign all required parameters before continuing.', 'Missing Parameters', 'error');
    return
end

% if ~isempty(find(cellfun(@isnan,data(:,2)))) || ~isempty(find(cellfun(@isnan,lengths(:,2))))
%     msgbox('Some parameters may be NaN. Please assign all required parameters before continuing.', 'Missing Parameters', 'error');
%     return
% end

if Parameters.RoadWidth < 1
    msgbox('Road Width must be greater than zero.','Parameters Error','error');
    return
end

if min(Parameters.Length) < 1
    msgbox('Span Length must be greater than zero.','Parameters Error','error');
    return
end

if Parameters.Deck.t < 1
    msgbox('Deck Thickness must be greater than zero.','Parameters Error','error');
    return
end

Parameters.Spans = get(handles.popupSpans, 'Value');

Parameters.Width = Parameters.Sidewalk.Left + Parameters.Sidewalk.Right + 2*Parameters.Barrier.Width + Parameters.RoadWidth;

set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', Parameters.Width});

% Save temprary parameters up to this point
P_Temp1 = Parameters;
setappdata(0, 'P_Temp1', P_Temp1);

% Run GetStructureConfig to fill in gaps in info
Parameters = GetStructureConfig([], Parameters, [], Options, []);

setappdata(0,'Parameters',Parameters);

function pushbtnCancel_Callback(hObject, eventdata, handles)
UserInputDeck_gui_CloseRequestFcn(handles.UserInputDeck_gui, eventdata, handles)

function popupSpans_Callback(hObject, eventdata, handles)
spans = get(hObject, 'Value');

data = cell(spans,2);
data(:,1) = {'Length:'};
set(handles.tableLengths, 'Data',data);

function popupmenuType_Callback(hObject, eventdata, handles)
type = get(hObject,'value');

data = get(handles.tableGeometry,'Data');

Parameters = getappdata(0, 'Parameters');

switch type
    case 1
        data{12,2} = Parameters.Beam.Fy;
        data{12,1} = 'Steel Fy [psi]';
        data = data(1:14,:);
    case 2
        data{12,2} = Parameters.Beam.fc;
        data{12,1} = 'Girder fc [psi]';
        data(15,:) = {'Diaphragm fc [psi]' Parameters.Dia.fc};
        data(16,:) = {'Prestressing Fu [ksi]' Parameters.Beam.PSSteel.Fu/1000};
    otherwise
end

set(handles.tableGeometry, 'Data', data);

% Set Field Names to Uneditable - Set Fields to Editable
editable = [false, true];
set(handles.tableGeometry, 'ColumnEditable', editable);

function tableGeometry_CellEditCallback(hObject, eventdata, handles)
Parameters = getappdata(0, 'Parameters');
data = get(handles.tableGeometry, 'Data');
OutToOutwidth = sum([data{1,2}, data{6,2}, data{7,2}, 2*data{9,2}]);

set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', OutToOutwidth});

function popupmenuType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
