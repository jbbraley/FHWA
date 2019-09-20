function varargout = LoadRating_gui(varargin)
% LOADRATING_GUI MATLAB code for LoadRating_gui.fig
%      Rates a Strand7 Finite Element Model using ASR and LRFR codes
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 12-Feb-2015 16:32:23

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

function LoadRating_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for LoadRating_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Assign Table Data
ColumnName = cell(1,1);
ColumnName(1,1) = {'Controlling'};
RowName = cell(2,1);
RowName(1,1) = {'Strength I'};
RowName(2,1) = {'Service II'};
% RowName(1,1) = {'Service II INV'};
% RowName(2,1) = {'Service II OP'};
FEMData = cell(2,1);
LineGirderData = cell(2,2);
set(handles.tableFEM, 'Data', FEMData);
set(handles.tableFEM, 'RowName',RowName);
set(handles.tableFEM, 'ColumnName', ColumnName);
set(handles.tableLineGirder, 'Data', LineGirderData);
set(handles.tableLineGirder,'RowName',RowName);
set(handles.tableLineGirder,'ColumnName',{'Interior';'Exterior'});

% Set defualts
set(handles.LRFD_radiobutton, 'value',1);
set(handles.RatingTruck_popupmenu, 'String', {'HL-93'});
set(handles.RatingTruck_popupmenu, 'Value', 1);


formatColorScheme(hObject);

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

function Overlay_checkbox_Callback(hObject, eventdata, handles)
if get(hObject,'value') == 1
    set(handles.Overlay_edit,'enable','on');    
else
    set(handles.Overlay_edit,'enable','off');
end

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

function RateModel_pushbutton_Callback(hObject, eventdata, handles)
% Get filenames from listboxes
modelname = get(handles.listbox1,'string');
metanames = get(handles.listbox2,'string');
CrawlSteps = 5;

% Get data from root
Parameters = getappdata(0,'Parameters');
Options = getappdata(0, 'Options');
Node = getappdata(0, 'Node');

% Set Column headers and clear old data
numGirder = Parameters.NumGirder;
ColumnName = cell(1,numGirder+1);
ColumnName(1,1) = {'Controlling'};
for t = 1:numGirder
    ColumnName(1,t+1) = {t};
end
set(handles.tableFEM,'ColumnName',ColumnName);

% Clear data tables
FEMdata = get(handles.tableFEM,'Data');
FEMdata = cell(size(FEMdata,1),size(FEMdata,2));
set(handles.tableFEM,'Data',FEMdata);

SingleLineData = get(handles.tableLineGirder,'Data');
SingleLineData = cell(size(SingleLineData,1),size(SingleLineData,2));
set(handles.tableLineGirder,'Data',SingleLineData);

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');
% Clear messages from previous load ratings
cell_listbox = cell_listbox(1);
msg{1} = 'Starting Load Rating...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

% Load Strand7 file
InitializeSt7;
uID = 1;
try
    St7OpenFile(uID, char(modelname), Options.St7.ScratchPath)
catch
end

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

% Stiffeners
if get(handles.TransStiff_checkbox, 'value')
    Parameters.Beam.Stiffeners.Spacing = str2double(get(handles.TransSpacing_edit, 'string'));
end

% Get Rating Code
if get(handles.LRFD_radiobutton, 'value') == 1
    Code = 'LRFD';
elseif get(handles.ASD_radiobutton,'value') == 1
    Code = 'ASD';
end
Parameters.Rating.Code = Code;

% Set structure hierarchy
Rating = ['Rating.' Parameters.Rating.Code];
% Get Rating Truck
Trucks = get(handles.RatingTruck_popupmenu,'string');
selectInd = get(handles.RatingTruck_popupmenu,'value');


Parameters.Rating.DesignTruckName = Trucks(selectInd);
if strcmp(Parameters.Rating.Code, 'ASD')
    Parameters.Rating.(Code).DesignLoad = '6';
else
    Parameters.Rating.(Code).DesignLoad = 'A';
end

% Notification Panel
msg{1} = 'Retrieving Truck Loads...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

Parameters.Rating.(Code) = GetTruckLoads(Parameters.Rating.(Code));
Parameters.Rating.(Code).useCB = get(handles.Cb_Checkbox,'value');% With moment gradient modifier
[Parameters, Parameters.Rating.(Code)] = AASHTOLoadRating(Parameters.Rating.(Code),Parameters);
% Apply dynamic (impact) factor to loads
Parameters.Rating.(Code).Load.A = Parameters.Rating.(Code).Load.A*Parameters.Rating.(Code).IMF;
Parameters.Rating.(Code).Load.TD = Parameters.Rating.(Code).Load.TD*Parameters.Rating.(Code).IMF;

%Write to root
setappdata(0,'Parameters',Parameters);

%% Apply Boundary Conditions to model
BCpress = getappdata(0,'BCpress');
if ~isempty(BCpress)
    % Notification Panel
    msg{1} = 'Applying Boundary Conditions...';
    cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);
   
    FreedomCase = 1;
    BoundaryConditions(uID,Node,Parameters,FreedomCase);
end

%% Run Load Rating Functions

%Change wearing surface in parameters
if get(handles.Overlay_checkbox,'value') == 1
    Parameters.Deck.WearingSurface = str2double(get(handles.Overlay_edit, 'string'));
end

% Apply Non-structural mass for overlay
if Parameters.Deck.WearingSurface~=0
    % Notification Panel
    msg{1} = 'Applying Overlay...';
    cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);
    
    % Apply to model (Load Case 2)
    AddOverlay(uID,Node,Parameters,Parameters.Deck.WearingSurface,2);
end

% Notification Panel
msg{1} = 'Retrieving Dead Load Responses...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

% Run DeadLoad Solver
ModelPath = getappdata(0,'pathname');
ModelName = getappdata(0,'fname');

DeadLoadSolver(uID,ModelName,ModelPath,Parameters,2);


% Run Dead Load Results
if exist([ModelPath ModelName '_1.lsa'],'file') == 2
    [DLResults] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters, 2);
    Parameters.Rating.(Code).FEM.DLR = DLResults;
end

% Notification Panel
msg{1} = 'Retrieving Live Load Responses...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

% Run Live Load Solver
LiveLoadSolver(uID, ModelName, ModelPath, Node, Parameters, Parameters.Rating.(Code), CrawlSteps, 3);
% Get Live Load Results
if exist([ModelPath ModelName '_LL.lsa'],'file') == 2
    [LLResults] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters, Parameters.Rating.(Code), 3);
    Parameters.Rating.(Code).FEM.LLR = LLResults;
end

%% Single Line Rating
Parameters.Rating.(Code).SL.Int = GetRatingFactor(Parameters.Beam.Int,Parameters.Demands.Int.SL,Parameters,'Int');
Parameters.Rating.(Code).SL.Ext = GetRatingFactor(Parameters.Beam.Ext,Parameters.Demands.Ext.SL,Parameters,'Ext');

% Notification Panel
msg{1} = 'Computing Rating Factors...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

if Parameters.Rating.(Code).NumLane <= 10
    [Parameters, Parameters.Rating.(Code).FEM] = FEMRatingFactors(Parameters,Parameters.Rating.(Code),Code);
end

% Display minimum strength I and Service II rating factors for FEM & Single
% Line Rating
SingleLineData = cell(2,2);
SingleLineData(1,1) = {[num2str(min(Parameters.Rating.(Code).SL.Int.St1.Inv),3),' / ',num2str(min(Parameters.Rating.(Code).SL.Int.St1.Op),3)]};
SingleLineData(1,2) = {[num2str(min(Parameters.Rating.(Code).SL.Ext.St1.Inv),3),' / ',num2str(min(Parameters.Rating.(Code).SL.Ext.St1.Op),3)]};
if isfield(Parameters.Rating.(Code).SL.Int, 'Sv2')
    SingleLineData(2,1) = {[num2str(min(Parameters.Rating.(Code).SL.Int.Sv2.Inv),3),' / ',num2str(min(Parameters.Rating.(Code).SL.Int.Sv2.Op),3)]};
    SingleLineData(2,2) = {[num2str(min(Parameters.Rating.(Code).SL.Ext.Sv2.Inv),3),' / ',num2str(min(Parameters.Rating.(Code).SL.Ext.Sv2.Op),3)]};
end

set(handles.tableLineGirder, 'Data', SingleLineData);

sizefactors = size(Parameters.Rating.(Code).FEM.Int.St1.RatingFactors_Inv,3);
numGirder = Parameters.NumGirder;

FEMdata = cell(2,numGirder+1);
St1_inv(2:numGirder-1) = min(min(Parameters.Rating.(Code).FEM.Int.St1.RatingFactors_Inv,[],3),[],2);
St1_inv([1 numGirder]) = min(min(Parameters.Rating.(Code).FEM.Ext.St1.RatingFactors_Inv,[],3),[],2);
St1_op(2:numGirder-1) = min(min(Parameters.Rating.(Code).FEM.Int.St1.RatingFactors_Op,[],3),[],2);
St1_op([1 numGirder]) = min(min(Parameters.Rating.(Code).FEM.Ext.St1.RatingFactors_Op,[],3),[],2);
FEMdata(1,1) = {[num2str(min(St1_inv),3) ' / ' num2str(min(St1_op),3)]}; %Controlling Strength I
if isfield(Parameters.Rating.(Code).FEM.Int, 'Sv2')
    Sv2_inv(2:numGirder-1) = min(min(Parameters.Rating.(Code).FEM.Int.Sv2.RatingFactors_Inv,[],3),[],2);
    Sv2_inv([1 numGirder]) = min(min(Parameters.Rating.(Code).FEM.Ext.Sv2.RatingFactors_Inv,[],3),[],2);
    Sv2_op(2:numGirder-1) = min(min(Parameters.Rating.(Code).FEM.Int.Sv2.RatingFactors_Op,[],3),[],2);
    Sv2_op([1 numGirder]) = min(min(Parameters.Rating.(Code).FEM.Ext.Sv2.RatingFactors_Op,[],3),[],2);
    FEMdata(2,1) = {[num2str(min(Sv2_inv),3) ' / ' num2str(min(Sv2_op),3)]}; %Controlling Service II
end
    
for k = 1:numGirder
    FEMdata(1,k+1) = {[num2str(St1_inv(k),3),' / ',num2str(St1_op(k),3)]};
    if exist('Sv2_inv','var')
    FEMdata(2,k+1) = {[num2str(Sv2_inv(k),3),' / ',num2str(Sv2_op(k),3)]};
    end
end

set(handles.tableFEM,'Data',FEMdata);

%% Display Moment Gradient, Cb
if Parameters.Rating.(Code).useCB
   set(handles.Cb_text, 'string', num2str(min(Parameters.Rating.(Code).Cb_int,Parameters.Rating.(Code).Cb_ext),3));
end

% %% Create Text Log File
msg{1} = 'Writing Results to Log File';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);

pathname = getappdata(0,'pathname');
fname = getappdata(0,'fname');
RatingLog(Parameters, Parameters.Rating.(Code).FEM, fname, pathname, Code);

% Write Parameters to root
setappdata(0,'Parameters',Parameters);

% Notification Panel
msg{1} = 'Load Rating Complete.';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);
CloseModelFile(uID);

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

function Cancel_pushbutton_Callback(hObject, eventdata, handles)  

figure1_CloseRequestFcn(LoadRating_gui, eventdata, handles)

function varargout = LoadRating_gui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

function listbox2_Callback(hObject, eventdata, handles)

function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox1_Callback(hObject, eventdata, handles)

function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RatingTruck_popupmenu_Callback(hObject, eventdata, handles)

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

function Overlay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Overlay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

function NotBox_Callback(hObject, eventdata, handles)

function NotBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NotBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text39_CreateFcn(hObject, eventdata, handles)

function WS_edit_Callback(hObject, eventdata, handles)

function WS_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TransStiff_checkbox_Callback(hObject, eventdata, handles)

function LongStiff_Checkbox_Callback(hObject, eventdata, handles)

function TransSpacing_edit_Callback(hObject, eventdata, handles)

function TransSpacing_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TransSpacing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)

function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Cb_Checkbox_Callback(hObject, eventdata, handles)

function Cb_text_Callback(hObject, eventdata, handles)

function Cb_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cb_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LRFD_radiobutton_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    set(handles.LRFD_radiobutton,'enable','inactive');
    set(handles.ASD_radiobutton, 'Value', 0);
    set(handles.ASD_radiobutton,'enable','on');
    set(handles.RatingTruck_popupmenu, 'String', {'HL-93'});
    set(handles.RatingTruck_popupmenu, 'Value', 1);
end

function ASD_radiobutton_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    set(handles.ASD_radiobutton,'enable','inactive');
    set(handles.LRFD_radiobutton, 'Value', 0);
    set(handles.LRFD_radiobutton,'enable','on');
    set(handles.RatingTruck_popupmenu, 'String', {''});
    set(handles.RatingTruck_popupmenu, 'String', {'HS-20 + Mod'});
    set(handles.RatingTruck_popupmenu, 'Value', 1);
end
