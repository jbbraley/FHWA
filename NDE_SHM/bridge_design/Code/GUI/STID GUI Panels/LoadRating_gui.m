function varargout = LoadRating_gui(varargin)
% LOADRATING_GUI MATLAB code for LoadRating_gui.fig
%      Rates a Strand7 Finite Element Model using ASR and LRFR codes
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 27-Apr-2015 17:08:20

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

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0, 'Options');

Options.handles.LoadRating_gui = handles;

% Set appdata 
setappdata(0, 'Options', Options);

% Set defaults
% Load rating truck info
set(handles.popupTruck, 'String', {'HL-93'});
set(handles.popupTruck, 'Value', 1);
set(handles.radiobtnLRFD, 'value',1);

% Only LRFD rating for Prestressed
if strcmp(Parameters.structureType,'Prestressed')
    set(handles.radiobtnASD,'enable','off')
end

% Stiffeners
set(handles.checkboxLongStiff, 'Value', 0);
set(handles.editLongStiff, 'enable', 'off');
set(handles.checkboxTransStiff, 'Value', 0);
set(handles.editTransStiff, 'enable', 'off');

% cb value
set(handles.checkboxCB, 'Value', 0);
set(handles.editCB, 'enable', 'off');

State = 'Init';
UpdateRatingTables(Parameters, Options, State);

% Num Girders in FEA table
set(handles.tableFEM, 'ColumnName', cellstr(num2str((1:Parameters.NumGirder)')));

function varargout = LoadRating_gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function LoadRating_gui_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

%% Options Functions
function radiobtnLRFD_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
    set(handles.radiobtnLRFD,'enable','inactive');
    set(handles.radiobtnASD, 'Value', 0);
    set(handles.radiobtnASD,'enable','on');
    set(handles.popupTruck, 'String', {'HL-93'});
    set(handles.popupTruck, 'Value', 1);
end

function radiobtnASD_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
    set(handles.radiobtnASD,'enable','inactive');
    set(handles.radiobtnLRFD, 'Value', 0);
    set(handles.radiobtnLRFD,'enable','on');
    set(handles.popupTruck, 'Value', 1);
    
    % Design Trucks
    tempcd = pwd;
    cd('../');
    load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
    cd(tempcd);
    
    set(handles.popupTruck, 'String', DesignTruckList);    
end

function checkboxTransStiff_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
   set(handles.editTransStiff,'enable','on'); 
else
   set(handles.editTransStiff, 'String', ''); 
   set(handles.editTransStiff,'enable','off');
end

function checkboxLongStiff_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
   set(handles.editLongStiff,'enable','on'); 
else
   set(handles.editLongStiff, 'String', ''); 
   set(handles.editLongStiff,'enable','off');
end

function checkboxCB_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
   set(handles.editCB,'enable','on'); 
else
   set(handles.editCB, 'String', ''); 
   set(handles.editCB,'enable','off');
end

%% Save/Rate/Cancel Buttons
function pushbtnSave_Callback(hObject, eventdata, handles)
% Get app data
Options = getappdata(0,'Options');
Parameters = getappdata(0,'Parameters');

% Prompt user for file location
[Filename, PathName] = uiputfile('.mat',...
    'DialogueTitle', [Options.PathName Options.FileName '_Para']);

% error screen no selection
if PathName == 0
    return
end

% save parameters
save([PathName Filename],'Parameters')

function pushbtnCancel_Callback(hObject, eventdata, handles)  
figure1_CloseRequestFcn(LoadRating_gui, eventdata, handles)

function pushbtnRateModel_Callback(hObject, eventdata, handles)
% Get data from root
Parameters = getappdata(0,'Parameters');
Options = getappdata(0, 'Options');
Node = getappdata(0, 'Node');

% Notification Panel
cell_listbox = get(handles.NotBox, 'string');

% Get Current GUI Options -------------------------------------------------
% Get Rating Code
if get(handles.radiobtnLRFD, 'value')
    Code = 'LRFD';
elseif get(handles.radiobtnASD,'value')
    Code = 'ASD';
end
Parameters.Rating.Code = Code;

% Get Rating Truck
Trucks = get(handles.popupTruck, 'string');
selectInd = get(handles.popupTruck, 'value');

% Stiffeners
if get(handles.checkboxTransStiff, 'value')
    Parameters.Beam.Stiffeners.Spacing = str2double(get(handles.editTransStiff, 'string'));
end
if get(handles.checkboxLongStiff, 'value')
    % INSERT LONG STIFF CODE
end

% Crawl steps
CrawlSteps = str2double(get(handles.editCrawlSteps, 'String'));
Options.LoadPath.CrawlSteps = CrawlSteps;

% CB
% With moment gradient modifier str2double(get(handles.editCB, 'String'));
Parameters.Rating.(Code).useCB = get(handles.checkboxCB, 'value'); 
Parameters.Rating.(Code).CB = str2double(get(handles.editCB, 'String'));

% Clear Past Tables ------------------------------------------------------
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


% Clear messages from previous load ratings
cell_listbox = cell_listbox(1);
msg{1} = 'Starting Load Rating...';
cell_listbox = AddNotString(handles.NotBox, msg, cell_listbox);


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
   set(handles.editCB, 'string', num2str(min(Parameters.Rating.(Code).Cb_int,Parameters.Rating.(Code).Cb_ext),3));
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
