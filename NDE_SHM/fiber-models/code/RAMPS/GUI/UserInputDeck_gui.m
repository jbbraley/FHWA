% 10/2/2014 (NPR): Added option for wearing surface and made all elements
% in GUI "normalized" to allow for resizing.


function varargout = UserInputDeck(varargin)
% Last Modified by GUIDE v2.5 03-Oct-2014 11:12:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputDeck_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputDeck_OutputFcn, ...
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

function UserInputDeck_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for UserInputBeamSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% % Center and Position
% % pixels
% set(handles.guiUserInputDeck, 'Units', 'pixels' );
% 
% % get your display size
% screenSize = get(0, 'ScreenSize');
% 
% % calculate the center of the display
% position = get(handles.guiUserInputDeck,'Position');
% position(1) = (screenSize(3)-position(3))/2;
% position(2) = (screenSize(4)-position(4))/2;
% 
% % center the window
% set(handles.guiUserInputDeck, 'Position', position);

% Spans
data = {'Length:', []}; 
set(handles.tableLengths, 'Data',data);
% set(handles.tableLengths, 'Units', 'pixels');
set(handles.tableLengths, 'ColumnWidth', {60, 70});

set(handles.popupSpans, 'String', 1:10);

% Type
types = {'Steel';'Prestressed'};
set(handles.popupmenuType,'string',types);

% Set Table Dims
% set(handles.tableGeometry, 'Units', 'pixels');
set(handles.tableGeometry, 'ColumnWidth', {180, 95});
% set(handles.tableOutToOutWidth, 'Units', 'pixels');
set(handles.tableOutToOutWidth, 'ColumnWidth', {150, 110});

% Set Field Names
data = cell(14,2);
data(:,1) = {'Road Width'; 'Near Skew'; 'Far Skew';...
        'Deck Thickness'; 'Sidewalk Height';...
        'Left Sidewalk Width'; 'Right Sidewalk Width';...
        'Barrier Height'; 'Barrier Width'; 'Wearing Surface';...
        'Deck fc [psi]'; 'Steel Fy [psi]';...
        'Barrier fc [psi]'; 'Sidewalk fc [psi]'};

if strcmp(Parameters.Geo, 'NBI')
    data{1,2} = Parameters.RoadWidth;
    data{2,2} = Parameters.SkewNear;
    data{3,2} = Parameters.SkewFar;
    data{4,2} = Parameters.Deck.t;
    data{5,2} = Parameters.Sidewalk.Height;
    data{6,2} = Parameters.Sidewalk.Left;
    data{7,2} = Parameters.Sidewalk.Right;
    data{8,2} = Parameters.Barrier.Height;
    data{9,2} = Parameters.Barrier.Width;
    data{10,2} = 0; %Wearing Surface
    data{11,2} = Parameters.Deck.fc;
    data{12,2} = Parameters.Beam.Fy;
    data{13,2} = Parameters.Barrier.fc;
    data{14,2} = Parameters.Sidewalk.fc;
    
    c = cell(1, Parameters.Spans);
    for i = 1:Parameters.Spans
        % code that generates v
        c{i} = num2str(i);
    end
    set(handles.popupSpans, 'String', c);
    set(handles.popupSpans, 'Value', Parameters.Spans, 'Enable', 'Inactive');
    
    spans = cell(Parameters.Spans, 2);
    spans(:,1) = {'Length'};
    spans(:,2) = {Parameters.Length};
    set(handles.tableLengths, 'Data', spans);
    
    set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', Parameters.Width});
else
    spans = {1:10};
    set(handles.popupSpans, 'Value', 1, 'Enable', 'on');
    
    Parameters.Spans = 1;
    
    set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', []});
    
    data{11,2} = Parameters.Deck.fc;
    data{12,2} = Parameters.Beam.Fy;
    data{13,2} = Parameters.Barrier.fc;
    data{14,2} = Parameters.Sidewalk.fc;
end
    
set(handles.tableGeometry, 'Data', data);

% Set Field Names to Uneditable - Set Fields to Editable
editable = [false, true];
set(handles.tableGeometry, 'ColumnEditable', editable);
set(handles.tableLengths, 'ColumnEditable', editable);
editable = [false, false];
set(handles.tableOutToOutWidth, 'ColumnEditable', editable);

Options.handles.guiUserInputDeck = handles.guiUserInputDeck;
setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function varargout = UserInputDeck_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% ------------------- assign and cancel -----------------------------------
function pushbtnAssign_Callback(hObject, eventdata, handles)
Options = getappdata(0, 'Options');
Parameters = getappdata(0,'Parameters');

type = get(handles.popupmenuType,'value');
data = get(handles.tableGeometry,'Data');
lengths = get(handles.tableLengths, 'Data');

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

Parameters.Deck.fc = data{11,2};

Parameters.Barrier.fc = data{13,2};
Parameters.Sidewalk.fc = data{14,2};

switch type
    case 1
        Parameters.Beam.Fy = data{12,2};
        Parameters.Beam.fc = 'NA';
        Parameters.Dia.fc = 'NA';
        Parameters.Beam.PSSteel.Fu = 'NA';
        Parameters.structureType = 'Steel';
    case 2
        Parameters.Beam.Fy = 'NA';
        Parameters.Beam.fc = data{12,2};
        Parameters.Dia.fc = data{15,2};
        Parameters.Beam.PSSteel.Fu = data{16,2}*1000;
        Parameters.structureType = 'Prestressed';
    otherwise
end


Parameters.Spans = get(handles.popupSpans, 'Value');

Parameters.Width = Parameters.Sidewalk.Left + Parameters.Sidewalk.Right + 2*Parameters.Barrier.Width + Parameters.RoadWidth;

set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', Parameters.Width});

setappdata(0,'Parameters',Parameters);

set(Options.handles.guiUserInputDeck, 'Visible', 'off');

function pushbtnCancel_Callback(hObject, eventdata, handles)
guiUserInputDeck_CloseRequestFcn(handles.guiUserInputDeck, eventdata, handles)

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
        
        

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuType

function guiUserInputDeck_CloseRequestFcn(hObject, eventdata, handles)
Options = getappdata(0,'Options');

Options.handles = rmfield(Options.handles,'guiUserInputDeck');
setappdata(0,'Options', Options);

delete(hObject);

function tableGeometry_CellEditCallback(hObject, eventdata, handles)
Parameters = getappdata(0, 'Parameters');
data = get(handles.tableGeometry, 'Data');
OutToOutwidth = sum([data{1,2}, data{6,2}, data{7,2}, 2*data{9,2}]);

set(handles.tableOutToOutWidth, 'Data', {'Out to Out Width:', OutToOutwidth});





% --- Executes during object creation, after setting all properties.
function popupmenuType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function tableOutToOutWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableOutToOutWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
