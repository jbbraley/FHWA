function varargout = ImportTestData_gui(varargin)
% IMPORTTESTDATA_GUI MATLAB code for ImportTestData_gui.fig
%      IMPORTTESTDATA_GUI, by itself, creates a new IMPORTTESTDATA_GUI or raises the existing
%      singleton*.
%
%      H = IMPORTTESTDATA_GUI returns the handle to a new IMPORTTESTDATA_GUI or the handle to
%      the existing singleton*.
%
%      IMPORTTESTDATA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTTESTDATA_GUI.M with the given input arguments.
%
%      IMPORTTESTDATA_GUI('Property','Value',...) creates a new IMPORTTESTDATA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImportTestData_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImportTestData_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImportTestData_gui

% Last Modified by GUIDE v2.5 09-Feb-2015 11:12:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImportTestData_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ImportTestData_gui_OutputFcn, ...
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


% --- Executes just before ImportTestData_gui is made visible.
function ImportTestData_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for ImportTestData_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global status previous_point

% initialize
status = '';  previous_point = []; 
OffsetData.CurrentAxis = 'X';
guiH = [];
setappdata(handles.guiImportTestData_gui,'guiH',guiH)
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

% Get raw results and send them to GetTestData
% results = varargin.('results');
results = varargin{1};
GetTestData(handles, results);
% Get node data
GetModelData(handles);

function varargout = ImportTestData_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% Buttons -----------------------------------------------------------------

function pushbtnImport_Callback(hObject, eventdata, handles)
% get app data
testData = getappdata(0,'testData');
gridDat = getappdata(0,'gridDat');

Xoff = str2double(get(handles.editXoff,'string'));
Yoff = str2double(get(handles.editYoff,'string'));

if isnan(Xoff)
    Xoff = 0;
end
if isnan(Yoff)
    Yoff = 0;
end

testData.coord(:,1) =  testData.coord(:,1) + Xoff;
testData.coord(:,2) =  testData.coord(:,2) + Yoff;

% Determined edge boundaries for test data using nodal data and add to test
% data
testData.xb = [gridDat.minGrid(:,1); gridDat.maxGrid(:,1)];
testData.yb = [gridDat.minGrid(:,2); gridDat.maxGrid(:,2)];

% Normalize mode shapes
largest_val = (-min(testData.U) < max(testData.U)).*(max(testData.U)-min(testData.U))+min(testData.U); 
testData.U = bsxfun(@rdivide,testData.U,largest_val);

% Get file location
[FileName, FilePath] = uiputfile([pwd '*.mat']);

save([FilePath, FileName], 'testData'); 

delete(handles.guiImportTestData_gui);

function pushbtnReset_Callback(hObject, eventdata, handles)
% get app data
gridData = getappdata(0,'gridDat');
testData = getappdata(0,'testData');
% Clear Axes
cla(handles.axesGrid)
set(handles.axesGrid,'XLimMode','auto');
set(handles.axesGrid,'YLimMode','auto');

% Re-initialize
guiH = [];
OffsetData.CurrentAxis = 'X';

set(handles.editYoff,'enable','off');
set(handles.editXoff,'string','');

set(handles.editXoff,'enable','on');
set(handles.editYoff,'string','');

setappdata(handles.guiImportTestData_gui,'guiH',guiH);
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData);

% Call print grid
printGrid(handles, gridData);

% Call print test
printTest(handles, testData)


% File Load Functions -----------------------------------------------------

function GetTestData(handles, results)
% Get Coordinate Data
testCoord = [];
% take all coordinate sets and put in one array
for i = 1:length(results.x)
    testCoord = [testCoord; [results.x{i}, results.y{i}]];
end
% find unique coordinate sets/remove repeated coordinates from different
% impacts 
testData.coord = unique(testCoord, 'rows');

% Get displacement data - put NaN in place for when mode shape is missing
% displacement at that coordinate
% mode shape array is a NxM array where
% N: total number of nodes across all shapes
% M: total number of mode shapes/freqs
testData.U = ones(length(testData.coord), length(results.freq))*NaN;
% make a column of displacements for each frequency
for i = 1:length(results.freq)
    % for each frequency, find valid displacement nodes
    [~, LOCB] = ismember([results.x{i}, results.y{i}], testData.coord, 'rows');  
    testData.U(LOCB,i) = results.U{i};
end

% convert from feet to inches
testData.coord = testData.coord*12; 

% get frequencies
testData.freq = results.freq;

% % toggle node plot to import
% IOtoggle = 'import';
% setappdata(0, 'IOtoggle', IOtoggle);

% Upload Data to App Data
setappdata(0, 'testData', testData);

% Print test nodes    
printTest(handles, testData);

function GetModelData(handles)
% Get Node File from root
Node = getappdata(0, 'Node');

% Get all node coords and IDs From Node
gridData.ID = nonzeros(vertcat(Node.ID));
gridData.coord(:,1) = horzcat(Node.x)';
gridData.coord(:,2) = horzcat(Node.y)';

% call function to sort nodes into grid and get boundaries
gridData = getGrid(gridData);

% % Set selectState back to '0'
% selectState = 'O';

% Call print grid
printGrid(handles, gridData);

% Upload Data to App Data
setappdata(0, 'gridDat', gridData);
% setappdata(0, 'selectState', selectState);

function gridData = getGrid(gridData)
% Get Boundaries of deck
gridData.gridColumn = unique(gridData.coord(:,2));
gridData.nearEdge = zeros(length(gridData.gridColumn),1);
gridData.farEdge = zeros(length(gridData.gridColumn),1);
for i = 1:length(gridData.gridColumn)
    gridData.nearEdge(i,1) = min(gridData.coord(gridData.coord(:,2) == gridData.gridColumn(i),1));
    gridData.nearEdge(i,2) = gridData.gridColumn(i);
    gridData.farEdge(i,1) = max(gridData.coord(gridData.coord(:,2) == gridData.gridColumn(i),1));
    gridData.farEdge(i,2) = gridData.gridColumn(i);
end

% Get x and y coords of min and maximum of grid
gridData.minGrid = [min(gridData.nearEdge(:,1))*ones(length(gridData.gridColumn),1), gridData.gridColumn];
gridData.maxGrid = [max(gridData.farEdge(:,1))*ones(length(gridData.gridColumn),1), gridData.gridColumn];

%% Graphical Functions -----------------------------------------------------
function printGrid(handles, gridDat)
% Reprint the Grid
guiH = getappdata(handles.guiImportTestData_gui,'guiH');
if isfield(guiH,'grid')
    delete(guiH.grid)
end
hold on
guiH.grid = scatter(handles.axesGrid, gridDat.coord(:,1), gridDat.coord(:,2),'b.');

scatter(gridDat.minGrid(:,1), gridDat.minGrid(:,2), 'r.');
scatter(gridDat.maxGrid(:,1), gridDat.maxGrid(:,2), 'r.');
hold off
setappdata(handles.guiImportTestData_gui,'guiH',guiH);

function printTest(handles, testData)
% Reprint the Grid
guiH = getappdata(handles.guiImportTestData_gui,'guiH');
if isfield(guiH,'test')
    delete(guiH.test)
end
hold on
guiH.test = scatter(handles.axesGrid, testData.coord(:,1), testData.coord(:,2),'go','fill');
hold off

if isfield(guiH,'xl')
    set(guiH.xl,'YData',get(gca,'YLim'));
end

if isfield(guiH,'yl')
    set(guiH.yl,'XData',get(gca,'XLim'));
end
setappdata(handles.guiImportTestData_gui,'guiH',guiH);


%% Window Callbacks --------------------------------------------------------

function guiImportTestData_gui_WindowButtonDownFcn(hObject, eventdata, handles)
global status previous_point 

% double check if these axes are indeed the current axes
if get(handles.guiImportTestData_gui, 'currentaxes') ~= gca, return, end

% perform appropriate action
switch lower(get(handles.guiImportTestData_gui, 'selectiontype'))
    case 'normal'
        previous_point = [];
        status = 'left';
    case 'open' % double click (left or right)
        previous_point = [];
        status = '';    
    case 'alt' % right click - pan
        status = 'right';
        previous_point = get(handles.axesGrid, 'CurrentPoint');
end

    
function guiImportTestData_gui_WindowButtonUpFcn(hObject, eventdata, handles)
global status

% double check if these axes are indeed the current axes
if get(handles.guiImportTestData_gui, 'currentaxes') ~= gca, return, end

% just reset status
status = '';

function guiImportTestData_gui_WindowScrollWheelFcn(hObject, eventdata, handles)
guiH = getappdata(handles.guiImportTestData_gui,'guiH');
% double check if these axes are indeed the current axes
if get(handles.guiImportTestData_gui, 'currentaxes') ~= gca, return, end
% get the amount of scolls
scrolls = eventdata.VerticalScrollCount;
% get the axes' x- and y-limits
xlim = get(gca, 'xlim');  ylim = get(gca, 'ylim');
% get the current camera position, and save the [z]-value
cam_pos_Z = get(gca, 'cameraposition');  cam_pos_Z = cam_pos_Z(3);
% get the current point
old_position = get(gca, 'CurrentPoint'); old_position(1,3) = cam_pos_Z;
% calculate zoom factor
zoomfactor = 1 - scrolls/15;
% adjust camera position
set(gca, 'cameratarget', [old_position(1, 1:2), 0],...
    'cameraposition', old_position(1, 1:3));
% adjust the camera view angle (equal to zooming in)
camzoom(zoomfactor);
% zooming with the camera has the side-effect of
% NOT adjusting the axes limits. We have to correct for this:
x_lim1 = (old_position(1,1) - min(xlim))/zoomfactor;
x_lim2 = (max(xlim) - old_position(1,1))/zoomfactor;
xlim   = [old_position(1,1) - x_lim1, old_position(1,1) + x_lim2];
y_lim1 = (old_position(1,2) - min(ylim))/zoomfactor;
y_lim2 = (max(ylim) - old_position(1,2))/zoomfactor;
ylim   = [old_position(1,2) - y_lim1, old_position(1,2) + y_lim2];
set(gca, 'xlim', xlim); set(gca, 'ylim', ylim);
% set new camera position
new_position = get(gca, 'CurrentPoint');
old_camera_target =  get(gca, 'CameraTarget');
old_camera_target(3) = cam_pos_Z;
new_camera_position = old_camera_target - ...
    (new_position(1,1:3) - old_camera_target(1,1:3));
% adjust camera target and position
set(gca, 'cameraposition', new_camera_position(1, 1:3),...
    'cameratarget', [new_camera_position(1, 1:2), 0]);
% we also have to re-set the axes to stretch-to-fill mode
set(gca, 'cameraviewanglemode', 'auto',...
    'camerapositionmode', 'auto',...
    'cameratargetmode', 'auto');

% Reset limits of offset lines
if isfield(guiH,'xl')
    set(guiH.xl,'YData',get(gca,'YLim'));
end

if isfield(guiH,'yl')
    set(guiH.yl,'XData',get(gca,'XLim'));
end

function guiImportTestData_gui_WindowButtonMotionFcn(hObject, eventdata, handles)
global status previous_point
guiH = getappdata(handles.guiImportTestData_gui,'guiH');

% double check if these axes are indeed the current axes
if get(handles.guiImportTestData_gui, 'currentaxes') ~= gca, return, end
% return if there isn't a previous point
if isempty(previous_point), return, end
% return if mouse hasn't been clicked
if isempty(status), return, end

if strcmp(status, 'right')
    % get current location (in pixels)
    current_point = get(gca, 'CurrentPoint');
    % get current XY-limits
    xlim = get(gca, 'xlim');  ylim = get(gca, 'ylim');
    % find change in position
    delta_points = current_point - previous_point;
    % adjust limits
    new_xlim = xlim - delta_points(1);
    new_ylim = ylim - delta_points(3);
    % set new limits
    set(gca, 'Xlim', new_xlim); set(gca, 'Ylim', new_ylim);
    % save new position
    previous_point = get(gca, 'CurrentPoint');
    
    if isfield(guiH,'xl')
        set(guiH.xl,'YData',get(gca,'YLim'));
    end
    
    if isfield(guiH,'yl')
        set(guiH.yl,'XData',get(gca,'XLim'));
    end
end

%% Axes Callbacks
%--------------------------------------------------------------------

% --- Executes on mouse press over axes background.
function axesGrid_ButtonDownFcn(hObject, eventdata, handles)
global status previous_point 

% double check if these axes are indeed the current axes
if get(handles.guiImportTestData_gui, 'currentaxes') ~= gca, return, end

% perform appropriate action
switch lower(get(handles.guiImportTestData_gui, 'selectiontype'))
    case 'normal'
        previous_point = [];
        status = 'left';
    case 'open' % double click (left or right)
        previous_point = [];
        status = '';    
    case 'alt' % right click - pan
        status = 'right';
        previous_point = get(handles.axesGrid, 'CurrentPoint');
end

if strcmp(status,'left')
gridDat = getappdata(0,'gridDat');
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');

% add XYZ to list for selection
coord_prime = [[gridDat.coord(:,1), gridDat.coord(:,2)]; gridDat.minGrid; gridDat.maxGrid];

% get current location (in pixels)
current_point = get(gca, 'CurrentPoint');

% Snap to closest grid point
current_point = current_point(1,1:2);
[~,dist] = min(sqrt((current_point(1) - coord_prime(:,1)).^2 + (current_point(2) - coord_prime(:,2)).^2));

% Assign offset amount
switch OffsetData.CurrentAxis
    case 'X'
        gridDat.axisX = dist;
        OffsetData.X = coord_prime(gridDat.axisX,1);

        set(handles.editYoff,'enable','on');
        set(handles.editXoff,'enable','off');
        OffsetData.CurrentAxis = 'Y';            
    case 'Y'
        gridDat.axisY = dist;
        OffsetData.Y = coord_prime(gridDat.axisY,2);

        set(handles.editXoff,'enable','on');
        set(handles.editYoff,'enable','off');
        OffsetData.CurrentAxis = 'X';
end

% Save data to root
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)
% Update axes and edit texts
updateImportTestData_gui(handles);
end

%% Edit Callbacks
%-----------------------------------------------------------------------

function editYoff_Callback(hObject, eventdata, handles)
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');
OffsetData.Y = str2double(get(hObject,'string'));

set(handles.editYoff,'enable','off');
set(handles.editXoff,'enable','on');
OffsetData.CurrentAxis = 'X';
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

%Update axes and text
updateImportTestData_gui(handles);

function editXoff_Callback(hObject, eventdata, handles)
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');
OffsetData.X = str2double(get(hObject,'string'));

set(handles.editYoff,'enable','on');
set(handles.editXoff,'enable','off');
OffsetData.CurrentAxis = 'Y';
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

%Update axes and text
updateImportTestData_gui(handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editXoff.
function editXoff_ButtonDownFcn(hObject, eventdata, handles)
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');
set(handles.editYoff,'enable','off');
set(handles.editXoff,'enable','on');
OffsetData.CurrentAxis = 'X';
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editYoff.
function editYoff_ButtonDownFcn(hObject, eventdata, handles)
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');
set(handles.editYoff,'enable','on');
set(handles.editXoff,'enable','off');
OffsetData.CurrentAxis = 'Y';
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

%% Sub Functions
%----------------------------------------------------------------------------
function updateImportTestData_gui(handles)
% Get data
OffsetData = getappdata(handles.guiImportTestData_gui,'OffsetData');
guiH = getappdata(handles.guiImportTestData_gui,'guiH');
testData = getappdata(0, 'testData');

% Update axes with line objects
if isfield(OffsetData,'X')
    if isfield(guiH,'xl')
        delete(guiH.xl)
    end
    hold on
    YLim = get(handles.axesGrid,'YLim');
    guiH.xl = line(OffsetData.X*ones(2,1),YLim,'Color','k');
    hold off
    
    % Write offset value to edit text
    set(handles.editXoff,'string',OffsetData.X)
    
    % Adjust test data coordinate values
    testData.coord(:,1) =  testData.coord(:,1) + OffsetData.X;
end
if isfield(OffsetData,'Y')
    if isfield(guiH,'yl')
        delete(guiH.yl)
    end
    hold on
    XLim = get(handles.axesGrid,'XLim');
    guiH.yl = line(XLim,OffsetData.Y*ones(2,1),'Color','k');
    hold off
    
    set(handles.editYoff,'string',OffsetData.Y)
    
    testData.coord(:,2) =  testData.coord(:,2) + OffsetData.Y;
end

% Save data to root
setappdata(handles.guiImportTestData_gui,'guiH',guiH)
setappdata(handles.guiImportTestData_gui,'OffsetData',OffsetData)

% Re-plot test coordinates
printTest(handles, testData);


%% Object Creation Functions
%-----------------------------------------------------------------------
function editYoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editYoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editXoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editXoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
