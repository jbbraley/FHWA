% 10.01.14 - jbb - Replaced Parameters.NumLane with Parameters.NumRatingLane

function varargout = LoadRating_gui(varargin)
% LOADRATING_GUI MATLAB code for LoadRating_gui.fig
%      Rates a Strand7 Finite Element Model using ASR and LRFR codes
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 29-Oct-2014 13:46:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LoadRating_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @LoadRating_gui_OutputFcn, ...
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


% --- Executes just before LoadRating_gui is made visible.
function LoadRating_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LoadRating_gui (see VARARGIN)

% Choose default command line output for LoadRating_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

formatColorScheme(hObject);

% ---------- Callback Functions -----------------
% -----------------------------------------------

% Browse Button1 callback
function BrowseModel_pushbutton_Callback(hObject, eventdata, handles)
% get files from user
[filename, pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
                                  'Select model file', ... 
                                  'MultiSelect' , 'off');

% error screen no selection
if pathname == 0
    return
end


% Create full file name
fullnames = {fullfile(pathname,filename)};

% Define Model Name
fname = filename(1:end-4);

% Notification Panel
set(handles.NotBox, 'value', 1);
msg = ['Model Loaded...' fname];
set(handles.NotBox, 'string', msg);
 
% update listbox string
set(handles.listbox1, 'string', fullnames);

% Check if filenames exist in directory
if exist([pathname fname '_Para.mat'],'file')==2
    meta_fnames{1} = fullfile(pathname,[fname '_Para.mat']);
end
if exist([pathname fname '_Options.mat'],'file')==2
    meta_fnames{2} = fullfile(pathname,[fname '_Options.mat']);
end
if exist([pathname fname '_Node.mat'],'file')==2
    meta_fnames{3} = fullfile(pathname,[fname '_Node.mat']);
end

% If corresponding meta files do not exist in directory prompt for
% selection 
if ~exist('meta_fnames','var') || length(meta_fnames)~=3
    [meta_filename, meta_pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
                                  'Select files', ... 
                                  'MultiSelect' , 'on');
  
    % Form cell array of filenames
    for ii = 1:length(meta_filename) 
        meta_fnames{ii} = fullfile(meta_pathname, meta_filename{ii});
    end
end

% Load meta .mat files
for ii = 1:length(meta_fnames)
    load(meta_fnames{ii});
end

% Save data to root
setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);
setappdata(0,'Node',Node);

%Get wearing surface info
set(handles.WS_edit, 'string', Parameters.Deck.WearingSurface);

% Set Defaults
% Only LRFD rating for Prestressed
if strcmp(Parameters.structureType,'Prestressed')
    set(handles.ASD_radiobutton,'enable','off')
end

% Update Listbox 2 string
set(handles.listbox2, 'string', meta_fnames);

% Write filename and pathname to appdata
setappdata(0,'fname',fname);
setappdata(0,'pathname',pathname);


% Meta Data Files Browse Button Callback
function BrowseData_pushbutton_Callback(hObject, eventdata, handles)
[meta_filename, meta_pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
                                  'Select files', ... 
                                  'MultiSelect' , 'on');
  
    % Form cell array of filenames
for ii = 1:length(meta_filename) 
    meta_fnames{ii} = fullfile(meta_pathname, meta_filename{ii});
end

% Update Listbox 2 string
set(handles.listbox2, 'string', meta_fnames);

% Clear Button Callback
function Clear_pushbutton_Callback(hObject, eventdata, handles)
% Get filenames from listbox 2
mdatanames = get(handles.listbox2,'string');
% Find which is selected
select = get(handles.listbox2,'value');
% Create index of filenames to be retained
NoFile = length(mdatanames);
newnamesInd = (1:NoFile)~=select;
mnames = mdatanames(newnamesInd);
% Update Listbox 2 string
set(handles.listbox2, 'string', mnames);

%% Load Button Callback
% function LoadData_pushbutton_Callback(hObject, eventdata, handles)
% 
% % Get filenames from listboxes
% modelname = get(handles.listbox1,'string');
% metanames = get(handles.listbox2,'string');
% 
% % Error screen for no model file
% if isempty(modelname)
%     % Inform user
%     fprintf('Please load Strand7 file\n');
%     return
% end
% % Error screen for inadequate selected files
% if length(metanames)~=3
%   %Inform User
%   fprintf('Only %i files selected. Please select 3 files.\n',length(metanames));
%   return
% end
% 
% % Load meta .mat files
% for ii = 1:length(metanames)
%     load(metanames{ii});
% end
% 
% % Load Strand7 file
% InitializeSt7;
% calllib('St7API','St7CloseFile',1);
% uID = 1;
% iErr = calllib('St7API', 'St7OpenFile', uID, char(modelname), Options.St7.ScratchPath);
% HandleError(iErr);
% 
% % Notification Panel
% cell_listbox = {get(handles.NotBox, 'string')};
% length_cell_listbox = length(cell_listbox);
% 
% msg{1} = 'Model Files Loaded...';
% 
% for ii = 1:length(msg)
%     cell_listbox{length_cell_listbox +ii} = msg{ii};
%     set(handles.NotBox, 'string', cell_listbox);
%     set(handles.NotBox, 'Value', length_cell_listbox +ii);
%     drawnow
% end
% 
% 
% % Save data to root
% setappdata(0,'Parameters',Parameters);
% setappdata(0,'Options',Options);
% setappdata(0,'Node',Node);
% 
% % Set Defaults
% % Only LRFD rating for Prestressed
% % if strcmp(Parameters.structureType,'Prestressed')
% %     set(handles.ASD_radiobutton,'enable','off')
% % end
% 
% % Autofill Parameter Edits
% set(handles.MOI_edit,'string',num2str(Parameters.Beam.Ix));
% set(handles.fc_edit,'string',num2str(Parameters.Deck.fc));
% set(handles.EDia_edit,'string',num2str(Parameters.Dia.E));

% Options CheckBoxes Callbacks
function Overlay_checkbox_Callback(hObject, eventdata, handles)
if get(hObject,'value') == 1
    set(handles.Overlay_edit,'enable',on);    
else
    set(handles.Overlay_edit,'enable',off);
end

% Rating Code Selection
function uipanel6_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel6 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
LRFD = get(handles.LRFD_radiobutton,'value');

% Design Trucks
tempcd = pwd;
cd('../');
load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
cd(tempcd);

if LRFD
    set(handles.RatingTruck_popupmenu,'String', {'HL-93'});
    set(handles.RatingTruck_popupmenu, 'Value', 1);
else
    set(handles.RatingTruck_popupmenu, 'String', DesignTruckList, 'Value', 6);
end

% Set Boundary Conditions
function BC_pushbutton_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
% Error Screen
if isempty(Parameters)
    %Inform User
    fprintf('Please load appropriate files');
    return
end
% Call UserInputBearings_Variable_gui
UserInputBearings_Variable_gui

% Set event
BCpress = 1;
setappdata(0,'BCpress',BCpress);


% Compile parameters and rate bridge
function RateModel_pushbutton_Callback(hObject, eventdata, handles)
% Get filenames from listboxes
modelname = get(handles.listbox1,'string');
metanames = get(handles.listbox2,'string');

% Get data from root
Parameters = getappdata(0,'Parameters');
Options = getappdata(0, 'Options');
Node = getappdata(0, 'Node');

% Load Strand7 file
InitializeSt7;
calllib('St7API','St7CloseFile',1);
uID = 1;
iErr = calllib('St7API', 'St7OpenFile', uID, char(modelname), Options.St7.ScratchPath);
HandleError(iErr);

%Error screen for no model file
if isempty(modelname)
    % Inform user
    msgbox('Please load Strand7 model file.', 'No Model File Selected', 'error');
    return
end

% Error screen for inadequate selected files
if length(metanames)~=3
  %Inform User
  fprintf('Only %i files selected. Please select 3 files.\n',length(metanames));
  return
end

% Error Screen for boundary conditions
if ~isfield(Parameters.Bearing.Fixed,'Fixity')
    % Inform User
    fprintf('Please assign boundary conditions before continuing');
    return
end

% Error screen for selected code
if get(handles.LRFD_radiobutton, 'value') == 0 && get(handles.ASD_radiobutton, 'value') == 0
    msgbox('Please select rating code.', 'Rating Code Not Selected', 'error');
    return
end



set(handles.text16,'string','--');
set(handles.text21,'string','--');
set(handles.text24,'string','--');
set(handles.text25,'string','--');
set(handles.text17,'string','--');
set(handles.text27,'string','--');
set(handles.text30,'string','--');
set(handles.text31,'string','--');

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);
msg{1} = 'Rating Model...';

if length_cell_listbox > 2
    set(handles.NotBox, 'value', 1);
    set(handles.NotBox, 'string', msg{1});
    cell_listbox = {get(handles.NotBox, 'string')};
else
    for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
    end
end

% Get Rating Code
ASDcheck = get(handles.ASD_radiobutton,'value');

if ASDcheck
    Parameters.Rating.Code = 'ASD';
else
    Parameters.Rating.Code = 'LRFD';
end

% Get Rating Truck
Trucks = get(handles.RatingTruck_popupmenu,'string');
selectInd = get(handles.RatingTruck_popupmenu,'value');

Parameters.Rating.DesignTruckName = Trucks(selectInd);
if ASDcheck
    Parameters.Rating.DesignLoad = num2str(selectInd);
else
    Parameters.Rating.DesignLoad = 'A';
end

% Notification Panel
if length(cell_listbox) == 1
else
    cell_listbox = get(handles.NotBox, 'string');
end

length_cell_listbox = length(cell_listbox);

msg{1} = 'Retrieving Truck Loads...';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
end

Parameters.Rating = GetTruckLoads(Parameters.Rating);


%% Get Lane width
% if ~isfield(Parameters,'NumLane')
%     Parameters.NumLane = floor(Parameters.RoadWidth/144);
% end

Parameters = AASHTOLoadRating(Parameters);

%Write to root
setappdata(0,'Parameters',Parameters);

% Get Node and Options structures from root
Node = getappdata(0,'Node');
Options = getappdata(0,'Options');
uID = 1;

%% Apply Boundary Conditions to model

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);

msg{1} = 'Applying Boundary Conditions...';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
    drawnow
end

BCpress = getappdata(0,'BCpress');
if ~isempty(BCpress)
    
    FreedomCase = 1;
    BoundaryConditions(uID,Node,Parameters,FreedomCase);
end

%% Run Load Rating Functions

%Change wearing surface in parameters
if get(handles.Overlay_checkbox,'value') == 1
    Parameters.Deck.WearingSurface = str2double(get(handles.Overlay_edit, 'string'));
else
    Parameters.Deck.WearingSurface = 0;
end

% Apply Non-structural mass for overlay
OverlayEvent = getappdata(0,'OverlayEvent');
if get(handles.Overlay_checkbox,'value') || ~isempty(OverlayEvent)
    % Record adding overlay
    OverlayEvent = 1;
    setappdata(0,'OverlayEvent',OverlayEvent);
    
    % Notification Panel
    cell_listbox = get(handles.NotBox, 'string');
    length_cell_listbox = length(cell_listbox);

    msg{1} = 'Applying Overlay...';

    for ii = 1:length(msg)
        cell_listbox{length_cell_listbox +ii} = msg{ii};
        set(handles.NotBox, 'string', cell_listbox);
        set(handles.NotBox, 'Value', length_cell_listbox +ii);
        drawnow
    end
    
    AddOverlay(uID,Node,Parameters,Parameters.Beam.WearingSurface,1);
end

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);

msg{1} = 'Retrieving Dead Load Responses...';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
    drawnow
end

% Run DeadLoad Solver
ModelPath = getappdata(0,'pathname');
ModelName = getappdata(0,'fname');

DeadLoadSolver(uID,ModelName,ModelPath,Node,Parameters);

% Run Dead Load Results
if exist([ModelPath ModelName '_1.lsa'],'file') == 2
    [DLResults] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters);
    Parameters.Rating.DLR = DLResults;
end

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);

msg{1} = 'Retrieving Live Load Responses...';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
    drawnow
end

% Run Live Load Solver
LiveLoadSolver(uID, Options, ModelName, ModelPath, Node, Parameters);

% Get Live Load Results
if exist([ModelPath ModelName '_LL.lsa'],'file') == 2
    [LLResults] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters);
    Parameters.Rating.LLR = LLResults;
end


% Check for existance of design Parameters
switch Parameters.structureType
    case 'Steel'
        if strcmp(Parameters.ModelType, 'Manual')
            Parameters_temp = Parameters;
            Parameters_temp.Design.DesignLoad = Parameters.Rating.DesignLoad;
            Parameters_temp.Design.Code = Parameters.Rating.Code;
            Parameters_temp = AASHTODesign(Parameters_temp);
            Parameters_temp = GetSectionForces(Parameters_temp);
            Parameters_temp = GetLRFDResistance(Parameters_temp);
            Parameters.Beam = Parameters_temp.Beam;
        end
    case 'Prestressed'
        if ~isfield(Parameters.Beam,'Mn_pos') || ~isfield(Parameters.Beam,'Fn_pos')
            Parameters_temp = Parameters;
            Parameters_temp.Design.DesignLoad = Parameters.Rating.DesignLoad;
            Parameters_temp.Design.Code = Parameters.Rating.Code;
            Parameters_temp.Design = GetTruckLoads(Parameters_temp.Design);
            Parameters_temp = AASHTODesign(Parameters_temp);
            Parameters = PSSectionForces(Parameters);
            Parameters_temp = PSGirderCapacity(Parameters_temp);
            Parameters.Beam = Parameters_temp.Beam;
        end
end

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);

msg{1} = 'Computing Rating Factors...';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
    drawnow
end

if Parameters.Rating.NumLane <= 10
    Parameters = FEMRatingFactors(Parameters,Options,ModelPath,ModelName);
end



%% Display minimum Strength 1 rating factor in GUI
set(handles.text16,'string',num2str(Parameters.Rating.St1.RFInv,3));
set(handles.text17,'string',num2str(Parameters.Rating.St1.RFOp,3));
% Display Inv Rating Location Info
set(handles.text21,'string',num2str(Parameters.Rating.St1.LocationInv(2)));
set(handles.text24, 'string', num2str(Parameters.Rating.St1.LocationInv(3)));
if Parameters.Rating.St1.LocationInv(1)==1
    if mod(Parameters.Spans,2) && Parameters.Rating.St1.LocationInv(3)==ceil(Parameters.Spans/2)
        Loc = 'Center Span';
    else
        Loc = '0.4 of Span';
    end
else
    Loc = ['Over Pier ' num2str(Parameters.Rating.St1.LocationInv(3))];
end
set(handles.text25, 'string', Loc)
% Display Op Rating Location Info
set(handles.text27,'string',num2str(Parameters.Rating.St1.LocationOp(2)));
set(handles.text30, 'string', num2str(Parameters.Rating.St1.LocationOp(3)));
if Parameters.Rating.St1.LocationInv(1)==1
    if mod(Parameters.Spans,2) && Parameters.Rating.St1.LocationOp(3)==ceil(Parameters.Spans/2)
        Loc = 'Center Span';
    else
        Loc = '0.4 of Span';
    end
else
    Loc = ['Over Pier ' num2str(Parameters.Rating.St1.LocationOp(3))];
end
set(handles.text31, 'string', Loc)

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);

msg{1} = 'Load Rating Complete.';

for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
end

%% Create Text Log File
pathname = getappdata(0,'pathname');
RatingLog(Parameters,Options, pathname);

% Write Parameters to root
setappdata(0,'Parameters',Parameters);



function Save_pushbutton_Callback(hObject, eventdata, handles)
% keyboard;
% Save Parameters to file
Parameters = getappdata(0,'Parameters');
fname = getappdata(0,'fname');
pathname = getappdata(0,'pathname');
% Prompt user for file location
[Filename, PathName] = uiputfile('.mat','DialogueTitle',[pathname fname '_Para']);

% error screen no selection
if PathName == 0
    return
end

save([PathName Filename],'Parameters')
% Close Strand7 file
uID = 1;
calllib('St7API','St7CloseFile',uID);



% Close UI
% figure1_CloseRequestFcn(LoadRating_gui, eventdata, handles)

% Close Window
function Cancel_pushbutton_Callback(hObject, eventdata, handles)  

figure1_CloseRequestFcn(LoadRating_gui, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = LoadRating_gui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in RatingTruck_popupmenu.
function RatingTruck_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to RatingTruck_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RatingTruck_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RatingTruck_popupmenu


% --- Executes during object creation, after setting all properties.
function RatingTruck_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RatingTruck_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Overlay_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Overlay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Overlay_edit as text
%        str2double(get(hObject,'String')) returns contents of Overlay_edit as a double


% --- Executes during object creation, after setting all properties.
function Overlay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Overlay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on selection change in NotBox.
function NotBox_Callback(hObject, eventdata, handles)
% hObject    handle to NotBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NotBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NotBox


% --- Executes during object creation, after setting all properties.
function NotBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NotBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function WS_edit_Callback(hObject, eventdata, handles)
% hObject    handle to WS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WS_edit as text
%        str2double(get(hObject,'String')) returns contents of WS_edit as a double


% --- Executes during object creation, after setting all properties.
function WS_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
