% 10/2/2014 (NPR): Set all elements in GUI to "normalized" to allow for
% resizing of gui.


function varargout = UserInputBearings_Variable_gui(varargin)
% Last Modified by GUIDE v2.5 02-Oct-2014 13:43:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputBearings_Variable_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputBearings_Variable_gui_OutputFcn, ...
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


% --- Executes just before UserInputBearings_Variable_gui is made visible.
function UserInputBearings_Variable_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInputBearings_Variable_gui (see VARARGIN)

% Choose default command line output for UserInputBeamSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

axes(handles.axesGrid);
old = cd('../');
imshow([pwd '\Img\GridAxes.jpg']);
cd(old);

% Bearing Fixity
set(handles.checkboxFixed_Fixed_U1, 'Value', Parameters.Bearing.Fixed.Fixity(1));
set(handles.checkboxFixed_Fixed_U2, 'Value', Parameters.Bearing.Fixed.Fixity(2));
set(handles.checkboxFixed_Fixed_U3, 'Value', Parameters.Bearing.Fixed.Fixity(3));
set(handles.checkboxFixed_Fixed_R1, 'Value', Parameters.Bearing.Fixed.Fixity(4));
set(handles.checkboxFixed_Fixed_R2, 'Value', Parameters.Bearing.Fixed.Fixity(5));
set(handles.checkboxFixed_Fixed_R3, 'Value', Parameters.Bearing.Fixed.Fixity(6));
set(handles.checkboxFixed_Fixed_Align, 'Value', Parameters.Bearing.Fixed.Fixity(7));
set(handles.checkboxFixed_Fixed_LongFix, 'Value', Parameters.Bearing.Fixed.Fixity(8));

set(handles.checkboxExpand_Fixed_U1, 'Value', Parameters.Bearing.Expansion.Fixity(1));
set(handles.checkboxExpand_Fixed_U2, 'Value', Parameters.Bearing.Expansion.Fixity(2));
set(handles.checkboxExpand_Fixed_U3, 'Value', Parameters.Bearing.Expansion.Fixity(3));
set(handles.checkboxExpand_Fixed_R1, 'Value', Parameters.Bearing.Expansion.Fixity(4));
set(handles.checkboxExpand_Fixed_R2, 'Value', Parameters.Bearing.Expansion.Fixity(5));
set(handles.checkboxExpand_Fixed_R3, 'Value', Parameters.Bearing.Expansion.Fixity(6));
set(handles.checkboxExpand_Fixed_Align, 'Value', Parameters.Bearing.Expansion.Fixity(7));
set(handles.checkboxExpand_Fixed_LongFix, 'Value', Parameters.Bearing.Expansion.Fixity(8));

if Parameters.Bearing.Fixed.Spring(1) ~= 0 
    set(handles.checkboxFixed_Spring_U1, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(2) ~= 0 
    set(handles.checkboxFixed_Spring_U2, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(3) ~= 0 
    set(handles.checkboxFixed_Spring_U3, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(4) ~= 0 
    set(handles.checkboxFixed_Spring_R1, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(5) ~= 0 
    set(handles.checkboxFixed_Spring_R2, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(6) ~= 0 
    set(handles.checkboxFixed_Spring_R3, 'Value', 1)
end
if Parameters.Bearing.Fixed.Spring(7) ~= 0 
    set(handles.checkboxFixed_Spring_Align, 'Value', 1)
end

if Parameters.Bearing.Expansion.Spring(1) ~= 0 
    set(handles.checkboxExpand_Spring_U1, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(2) ~= 0 
    set(handles.checkboxExpand_Spring_U2, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(3) ~= 0 
    set(handles.checkboxExpand_Spring_U3, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(4) ~= 0 
    set(handles.checkboxExpand_Spring_R1, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(5) ~= 0 
    set(handles.checkboxExpand_Spring_R2, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(6) ~= 0 
    set(handles.checkboxExpand_Spring_R3, 'Value', 1)
end
if Parameters.Bearing.Expansion.Spring(7) ~= 0 
    set(handles.checkboxExpand_Spring_Align, 'Value', 1)
end

% link spring values
set(handles.checkboxLinkU1, 'Value', Parameters.Bearing.Linked(1));
set(handles.checkboxLinkU2, 'Value', Parameters.Bearing.Linked(2));
set(handles.checkboxLinkU3, 'Value', Parameters.Bearing.Linked(3));
set(handles.checkboxLinkR1, 'Value', Parameters.Bearing.Linked(4));
set(handles.checkboxLinkR2, 'Value', Parameters.Bearing.Linked(5));
set(handles.checkboxLinkR3, 'Value', Parameters.Bearing.Linked(6));
set(handles.checkboxLinkAlign, 'Value', Parameters.Bearing.Linked(7));

% Bearing spring values
set(handles.editFixed_Spring_U1, 'String', num2str(Parameters.Bearing.Fixed.Spring(1)));
set(handles.editFixed_Spring_U2, 'String', num2str(Parameters.Bearing.Fixed.Spring(2)));
set(handles.editFixed_Spring_U3, 'String', num2str(Parameters.Bearing.Fixed.Spring(3)));
set(handles.editFixed_Spring_R1, 'String', num2str(Parameters.Bearing.Fixed.Spring(4)));
set(handles.editFixed_Spring_R2, 'String', num2str(Parameters.Bearing.Fixed.Spring(5)));
set(handles.editFixed_Spring_R3, 'String', num2str(Parameters.Bearing.Fixed.Spring(6)));
set(handles.editFixed_Spring_Align, 'String', num2str(Parameters.Bearing.Fixed.Spring(7)));

if Parameters.Bearing.Linked(1)
    set(handles.editExpand_Spring_U1, 'String', num2str(Parameters.Bearing.Fixed.Spring(1)));
else
    set(handles.editExpand_Spring_U1, 'String', num2str(Parameters.Bearing.Expansion.Spring(1)));
end
if Parameters.Bearing.Linked(2)
    set(handles.editExpand_Spring_U2, 'String', num2str(Parameters.Bearing.Fixed.Spring(2)));
else
    set(handles.editExpand_Spring_U2, 'String', num2str(Parameters.Bearing.Expansion.Spring(2)));
end
if Parameters.Bearing.Linked(3)
    set(handles.editExpand_Spring_U3, 'String', num2str(Parameters.Bearing.Fixed.Spring(3)));
else
    set(handles.editExpand_Spring_U3, 'String', num2str(Parameters.Bearing.Expansion.Spring(3)));
end
if Parameters.Bearing.Linked(4)
    set(handles.editExpand_Spring_R1, 'String', num2str(Parameters.Bearing.Fixed.Spring(4)));
else
    set(handles.editExpand_Spring_R1, 'String', num2str(Parameters.Bearing.Expansion.Spring(4)));
end
if Parameters.Bearing.Linked(5)
    set(handles.editExpand_Spring_R2, 'String', num2str(Parameters.Bearing.Fixed.Spring(5)));
else
    set(handles.editExpand_Spring_R2, 'String', num2str(Parameters.Bearing.Expansion.Spring(5)));
end
if Parameters.Bearing.Linked(6)
    set(handles.editExpand_Spring_R3, 'String', num2str(Parameters.Bearing.Fixed.Spring(6)));
else
    set(handles.editExpand_Spring_R3, 'String', num2str(Parameters.Bearing.Expansion.Spring(6)));
end
if Parameters.Bearing.Linked(7)
    set(handles.editExpand_Spring_Align, 'String', num2str(Parameters.Bearing.Fixed.Spring(7)));
else
    set(handles.editExpand_Spring_Align, 'String', num2str(Parameters.Bearing.Expansion.Spring(7)));
end


% Alpha Values
for i = 1:length(Parameters.Bearing.Fixed.Alpha)
    Data{i,1} = Parameters.Bearing.Fixed.Alpha(i,2);     
    Data{i,2} = Parameters.Bearing.Fixed.Alpha(i,3); 
    Data{i,3} = Parameters.Bearing.Expansion.Alpha(i,2);
    Data{i,4} = Parameters.Bearing.Expansion.Alpha(i,3);
end

set(handles.uitableAlphaValues,'Data',Data);

% Bearing Type
data = cell(Parameters.Spans+1,2);
for i=1:Parameters.Spans+1
    data{i,1} = ['Bearing ' num2str(i) ':'];
    data{i,2} = false;
end    

set(handles.uitableBearingType, 'columnFormat', {'char', 'logical'},...
                                'Data', data,...
                                'ColumnEditable', [false, true]);
                            
Options.handles.guiUserInputBearings_Variable_gui = handles.guiUserInputBearings_Variable_gui;
setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

function guiUserInputBearings_Variable_gui_CloseRequestFcn(hObject, eventdata, handles)
Options = getappdata(0, 'Options');
Options.handles = rmfield(Options.handles, 'guiUserInputBearings_Variable_gui');
setappdata(0, 'Options', Options);

delete(hObject);

function varargout = UserInputBearings_Variable_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% -------------------------------------------------------------------------

function pushbtnAssign_Callback(hObject, eventdata, handles)
output = GetFieldValues(handles);

Parameters = getappdata(0,'Parameters');
Node = getappdata(0,'Node');
Options = getappdata(0,'Options');

FCaseNum = 1;

BoundaryConditions(Options.St7.uID, Node, Parameters, FCaseNum);

iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

guiUserInputBearings_Variable_gui_CloseRequestFcn(handles.guiUserInputBearings_Variable_gui, eventdata, handles)
% set(handles.guiUserInputBearings_Variable_gui, 'Visible', 'off');

function pushbtnCancel_Callback(hObject, eventdata, handles)
guiUserInputBearings_Variable_gui_CloseRequestFcn(handles.guiUserInputBearings_Variable_gui, eventdata, handles)

function pushbtnRunSensitivity_Callback(hObject, eventdata, handles)
output = GetFieldValues(handles);

% determine senstive boundary ranges
BearingSensitivity_gui();
uiwait;

Parameters = getappdata(0,'Parameters');

% apply to uitable
% Alpha Values
for i = 1:length(Parameters.Bearing.Fixed.Alpha)
    Data{i,1} = Parameters.Bearing.Fixed.Alpha(i,2);     
    Data{i,2} = Parameters.Bearing.Fixed.Alpha(i,3); 
    Data{i,3} = Parameters.Bearing.Expansion.Alpha(i,2);
    Data{i,4} = Parameters.Bearing.Expansion.Alpha(i,3);
end
set(handles.uitableAlphaValues,'Data',Data);

Parameters.Bearing.Fixed.Alpha(:,1) = zeros(7,1);
Parameters.Bearing.Expansion.Alpha(:,1) = zeros(7,1);

% Spring values
set(handles.editFixed_Spring_U1, 'String', num2str(Parameters.Bearing.Fixed.Spring(1)));
set(handles.editFixed_Spring_U2, 'String', num2str(Parameters.Bearing.Fixed.Spring(2)));
set(handles.editFixed_Spring_U3, 'String', num2str(Parameters.Bearing.Fixed.Spring(3)));
set(handles.editFixed_Spring_R1, 'String', num2str(Parameters.Bearing.Fixed.Spring(4)));
set(handles.editFixed_Spring_R2, 'String', num2str(Parameters.Bearing.Fixed.Spring(5)));
set(handles.editFixed_Spring_R3, 'String', num2str(Parameters.Bearing.Fixed.Spring(6)));
set(handles.editFixed_Spring_Align, 'String', num2str(Parameters.Bearing.Fixed.Spring(7)));

set(handles.editExpand_Spring_U1, 'String', num2str(Parameters.Bearing.Expansion.Spring(1)));
set(handles.editExpand_Spring_U2, 'String', num2str(Parameters.Bearing.Expansion.Spring(2)));
set(handles.editExpand_Spring_U3, 'String', num2str(Parameters.Bearing.Expansion.Spring(3)));
set(handles.editExpand_Spring_R1, 'String', num2str(Parameters.Bearing.Expansion.Spring(4)));
set(handles.editExpand_Spring_R2, 'String', num2str(Parameters.Bearing.Expansion.Spring(5)));
set(handles.editExpand_Spring_R3, 'String', num2str(Parameters.Bearing.Expansion.Spring(6)));
set(handles.editExpand_Spring_Align, 'String', num2str(Parameters.Bearing.Expansion.Spring(7)));

function uitableBearingType_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitableBearingType (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

data=get(hObject,'Data'); % get the data cell array of the table
cols=get(hObject,'ColumnFormat'); % get the column formats
if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
    if eventdata.EditData % if the checkbox was set to true
        data{eventdata.Indices(1),eventdata.Indices(2)}=true; % set the data value to true
    else % if the checkbox was set to false
        data{eventdata.Indices(1),eventdata.Indices(2)}=false; % set the data value to false
    end
end
set(hObject,'Data',data); % now set the table's data to the updated data cell array

function output = GetFieldValues(handles)
Parameters = getappdata(0,'Parameters');

Parameters.Bearing.Fixed.Fixity(1) = get(handles.checkboxFixed_Fixed_U1, 'Value');
Parameters.Bearing.Fixed.Fixity(2) = get(handles.checkboxFixed_Fixed_U2, 'Value');
Parameters.Bearing.Fixed.Fixity(3) = get(handles.checkboxFixed_Fixed_U3, 'Value');
Parameters.Bearing.Fixed.Fixity(4) = get(handles.checkboxFixed_Fixed_R1, 'Value');
Parameters.Bearing.Fixed.Fixity(5) = get(handles.checkboxFixed_Fixed_R2, 'Value');
Parameters.Bearing.Fixed.Fixity(6) = get(handles.checkboxFixed_Fixed_R3, 'Value');
Parameters.Bearing.Fixed.Fixity(7) = get(handles.checkboxFixed_Fixed_Align, 'Value');
Parameters.Bearing.Fixed.Fixity(8) = get(handles.checkboxFixed_Fixed_LongFix, 'Value');

Parameters.Bearing.Fixed.Update(1) = get(handles.checkboxFixed_Update_U1, 'Value');
Parameters.Bearing.Fixed.Update(2) = get(handles.checkboxFixed_Update_U2, 'Value');
Parameters.Bearing.Fixed.Update(3) = get(handles.checkboxFixed_Update_U3, 'Value');
Parameters.Bearing.Fixed.Update(4) = get(handles.checkboxFixed_Update_R1, 'Value');
Parameters.Bearing.Fixed.Update(5) = get(handles.checkboxFixed_Update_R2, 'Value');
Parameters.Bearing.Fixed.Update(6) = get(handles.checkboxFixed_Update_R3, 'Value');
Parameters.Bearing.Fixed.Update(7) = get(handles.checkboxFixed_Update_Align, 'Value');

Parameters.Bearing.Fixed.Spring = zeros(1,7);
if get(handles.checkboxFixed_Spring_U1, 'Value')
    Parameters.Bearing.Fixed.Spring(1) = str2double(get(handles.editFixed_Spring_U1, 'String'));
else
    Parameters.Bearing.Fixed.Spring(1) = 0;
end
if get(handles.checkboxFixed_Spring_U2, 'Value')
    Parameters.Bearing.Fixed.Spring(2) = str2double(get(handles.editFixed_Spring_U2, 'String'));
else
    Parameters.Bearing.Fixed.Spring(2) = 0;
end
if get(handles.checkboxFixed_Spring_U3, 'Value')
    Parameters.Bearing.Fixed.Spring(3) = str2double(get(handles.editFixed_Spring_U3, 'String'));
else
    Parameters.Bearing.Fixed.Spring(3) = 0;
end
if get(handles.checkboxFixed_Spring_R1, 'Value')
    Parameters.Bearing.Fixed.Spring(4) = str2double(get(handles.editFixed_Spring_R1, 'String'));
else
    Parameters.Bearing.Fixed.Spring(4) = 0;
end
if get(handles.checkboxFixed_Spring_R2, 'Value')
    Parameters.Bearing.Fixed.Spring(5) = str2double(get(handles.editFixed_Spring_R2, 'String'));
else
    Parameters.Bearing.Fixed.Spring(5) = 0;
end
if get(handles.checkboxFixed_Spring_R3, 'Value')
    Parameters.Bearing.Fixed.Spring(6) = str2double(get(handles.editFixed_Spring_R3, 'String'));
else
    Parameters.Bearing.Fixed.Spring(6) = 0;
end
if get(handles.checkboxFixed_Spring_Align, 'Value')
    Parameters.Bearing.Fixed.Spring(7) = str2double(get(handles.editFixed_Spring_Align, 'String'));
else
    Parameters.Bearing.Fixed.Spring(7) = 0;
end
 
Parameters.Bearing.Expansion.Fixity(1) = get(handles.checkboxExpand_Fixed_U1, 'Value');
Parameters.Bearing.Expansion.Fixity(2) = get(handles.checkboxExpand_Fixed_U2, 'Value');
Parameters.Bearing.Expansion.Fixity(3) = get(handles.checkboxExpand_Fixed_U3, 'Value');
Parameters.Bearing.Expansion.Fixity(4) = get(handles.checkboxExpand_Fixed_R1, 'Value');
Parameters.Bearing.Expansion.Fixity(5) = get(handles.checkboxExpand_Fixed_R2, 'Value');
Parameters.Bearing.Expansion.Fixity(6) = get(handles.checkboxExpand_Fixed_R3, 'Value');
Parameters.Bearing.Expansion.Fixity(7) = get(handles.checkboxExpand_Fixed_Align, 'Value');
Parameters.Bearing.Expansion.Fixity(8) = get(handles.checkboxExpand_Fixed_LongFix, 'Value');

Parameters.Bearing.Expansion.Update(1) = get(handles.checkboxExpand_Update_U1, 'Value');
Parameters.Bearing.Expansion.Update(2) = get(handles.checkboxExpand_Update_U2, 'Value');
Parameters.Bearing.Expansion.Update(3) = get(handles.checkboxExpand_Update_U3, 'Value');
Parameters.Bearing.Expansion.Update(4) = get(handles.checkboxExpand_Update_R1, 'Value');
Parameters.Bearing.Expansion.Update(5) = get(handles.checkboxExpand_Update_R2, 'Value');
Parameters.Bearing.Expansion.Update(6) = get(handles.checkboxExpand_Update_R3, 'Value');
Parameters.Bearing.Expansion.Update(7) = get(handles.checkboxExpand_Update_Align, 'Value');

Parameters.Bearing.Linked(1) = get(handles.checkboxLinkU1, 'Value');
Parameters.Bearing.Linked(2) = get(handles.checkboxLinkU2, 'Value');
Parameters.Bearing.Linked(3) = get(handles.checkboxLinkU3, 'Value');
Parameters.Bearing.Linked(4) = get(handles.checkboxLinkR1, 'Value');
Parameters.Bearing.Linked(5) = get(handles.checkboxLinkR2, 'Value');
Parameters.Bearing.Linked(6) = get(handles.checkboxLinkR3, 'Value');
Parameters.Bearing.Linked(7) = get(handles.checkboxLinkAlign, 'Value');

if Parameters.Bearing.Linked(1)
    Parameters.Bearing.Expansion.Spring(1) = str2double(get(handles.editFixed_Spring_U1, 'String'));
elseif get(handles.checkboxExpand_Spring_U1, 'Value')
    Parameters.Bearing.Expansion.Spring(1) = str2double(get(handles.editExpand_Spring_U1, 'String'));
else
    Parameters.Bearing.Expansion.Spring(1) = 0;
end
if Parameters.Bearing.Linked(2)
    Parameters.Bearing.Expansion.Spring(2) = str2double(get(handles.editFixed_Spring_U2, 'String'));
elseif get(handles.checkboxExpand_Spring_U2, 'Value')
    Parameters.Bearing.Expansion.Spring(2) = str2double(get(handles.editExpand_Spring_U2, 'String'));
else
    Parameters.Bearing.Expansion.Spring(2) = 0;
end
if Parameters.Bearing.Linked(3)
    Parameters.Bearing.Expansion.Spring(3) = str2double(get(handles.editFixed_Spring_U3, 'String'));
elseif get(handles.checkboxExpand_Spring_U3, 'Value')
    Parameters.Bearing.Expansion.Spring(3) = str2double(get(handles.editExpand_Spring_U3, 'String'));
else
    Parameters.Bearing.Expansion.Spring(3) = 0;
end
if Parameters.Bearing.Linked(4)
    Parameters.Bearing.Expansion.Spring(4) = str2double(get(handles.editFixed_Spring_R1, 'String'));
elseif get(handles.checkboxExpand_Spring_R1, 'Value')
    Parameters.Bearing.Expansion.Spring(4) = str2double(get(handles.editExpand_Spring_R1, 'String'));
else
    Parameters.Bearing.Expansion.Spring(4) = 0;
end
if Parameters.Bearing.Linked(5)
    Parameters.Bearing.Expansion.Spring(5) = str2double(get(handles.editFixed_Spring_R2, 'String'));
elseif get(handles.checkboxExpand_Spring_R2, 'Value')
    Parameters.Bearing.Expansion.Spring(5) = str2double(get(handles.editExpand_Spring_R2, 'String'));
else
    Parameters.Bearing.Expansion.Spring(5) = 0;
end
if Parameters.Bearing.Linked(6)
    Parameters.Bearing.Expansion.Spring(6) = str2double(get(handles.editFixed_Spring_R3, 'String'));
elseif get(handles.checkboxExpand_Spring_R3, 'Value')
    Parameters.Bearing.Expansion.Spring(6) = str2double(get(handles.editExpand_Spring_R3, 'String'));
else
    Parameters.Bearing.Expansion.Spring(6) = 0;
end
if Parameters.Bearing.Linked(7)
    Parameters.Bearing.Expansion.Spring(7) = str2double(get(handles.editFixed_Spring_Align, 'String'));
elseif get(handles.checkboxExpand_Spring_Align, 'Value')
    Parameters.Bearing.Expansion.Spring(7) = str2double(get(handles.editExpand_Spring_Align, 'String'));
else
    Parameters.Bearing.Expansion.Spring(7) = 0;
end

bearingtype = get(handles.uitableBearingType, 'Data');
Parameters.Bearing.Type = cell2mat(bearingtype(:,2));
  
Data = get(handles.uitableAlphaValues, 'Data');
Parameters.Bearing.Fixed.Alpha(:,2) = cell2mat(Data(:,1));
Parameters.Bearing.Fixed.Alpha(:,3) = cell2mat(Data(:,2));
Parameters.Bearing.Expansion.Alpha(:,2) = cell2mat(Data(:,3));
Parameters.Bearing.Expansion.Alpha(:,3) = cell2mat(Data(:,4));

Parameters.Bearing.Fixed.Alpha(:,1) = zeros(7,1);
Parameters.Bearing.Expansion.Alpha(:,1) = zeros(7,1);

setappdata(0,'Parameters', Parameters);

output = [];

% Fixed Bearing Checkboxes --------------------------------------------

function checkboxFixed_Fixed_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U1, 'Value', 1);
    set(handles.checkboxFixed_Spring_U1, 'Value', 0);
    set(handles.checkboxFixed_Update_U1, 'Value', 0);
end

function checkboxFixed_Fixed_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U2, 'Value', 1);
    set(handles.checkboxFixed_Spring_U2, 'Value', 0);
    set(handles.checkboxFixed_Update_U2, 'Value', 0);
end

function checkboxFixed_Fixed_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U3, 'Value', 1);
    set(handles.checkboxFixed_Spring_U3, 'Value', 0);
    set(handles.checkboxFixed_Update_U3, 'Value', 0);
end

function checkboxFixed_Fixed_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R1, 'Value', 1);
    set(handles.checkboxFixed_Spring_R1, 'Value', 0);
    set(handles.checkboxFixed_Update_R1, 'Value', 0);
end

function checkboxFixed_Fixed_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R2, 'Value', 1);
    set(handles.checkboxFixed_Spring_R2, 'Value', 0);
    set(handles.checkboxFixed_Update_R2, 'Value', 0);
end

function checkboxFixed_Fixed_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R3, 'Value', 1);
    set(handles.checkboxFixed_Spring_R3, 'Value', 0);
    set(handles.checkboxFixed_Update_R3, 'Value', 0);
end

function checkboxFixed_Fixed_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_Align, 'Value', 1);
    set(handles.checkboxFixed_Spring_Align, 'Value', 0);
    set(handles.checkboxFixed_Update_Align, 'Value', 0);
end

function checkboxFixed_Fixed_LongFix_Callback(hObject, eventdata, handles)

function checkboxFixed_Spring_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U1, 'Value', 0);
    set(handles.checkboxFixed_Spring_U1, 'Value', 1);
end

function checkboxFixed_Spring_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U2, 'Value', 0);
    set(handles.checkboxFixed_Spring_U2, 'Value', 1);
end

function checkboxFixed_Spring_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_U3, 'Value', 0);
    set(handles.checkboxFixed_Spring_U3, 'Value', 1);
end

function checkboxFixed_Spring_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R1, 'Value', 0);
    set(handles.checkboxFixed_Spring_R1, 'Value', 1);
end

function checkboxFixed_Spring_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R2, 'Value', 0);
    set(handles.checkboxFixed_Spring_R2, 'Value', 1);
end

function checkboxFixed_Spring_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_R3, 'Value', 0);
    set(handles.checkboxFixed_Spring_R3, 'Value', 1);
end

function checkboxFixed_Spring_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Fixed_Align, 'Value', 0);
    set(handles.checkboxFixed_Spring_Align, 'Value', 1);
end

% Expansion Bearing Checkboxes --------------------------------------------

function checkboxExpand_Fixed_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U1, 'Value', 1);
    set(handles.checkboxExpand_Spring_U1, 'Value', 0);
    set(handles.checkboxExpand_Update_U1, 'Value', 0);
end

function checkboxExpand_Fixed_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U2, 'Value', 1);
    set(handles.checkboxExpand_Spring_U2, 'Value', 0);
    set(handles.checkboxExpand_Update_U2, 'Value', 0);
end

function checkboxExpand_Fixed_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U3, 'Value', 1);
    set(handles.checkboxExpand_Spring_U3, 'Value', 0);
    set(handles.checkboxExpand_Update_U3, 'Value', 0);
end

function checkboxExpand_Fixed_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R1, 'Value', 1);
    set(handles.checkboxExpand_Spring_R1, 'Value', 0);
    set(handles.checkboxExpand_Update_R1, 'Value', 0);
end

function checkboxExpand_Fixed_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R2, 'Value', 1);
    set(handles.checkboxExpand_Spring_R2, 'Value', 0);
    set(handles.checkboxExpand_Update_R2, 'Value', 0);
end

function checkboxExpand_Fixed_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R3, 'Value', 1);
    set(handles.checkboxExpand_Spring_R3, 'Value', 0);
    set(handles.checkboxExpand_Update_R3, 'Value', 0);
end

function checkboxExpand_Fixed_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_Align, 'Value', 1);
    set(handles.checkboxExpand_Spring_Align, 'Value', 0);
    set(handles.checkboxExpand_Update_Align, 'Value', 0);
end

function checkboxExpand_Fixed_LongFix_Callback(hObject, eventdata, handles)


function checkboxExpand_Spring_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U1, 'Value', 0);
    set(handles.checkboxExpand_Spring_U1, 'Value', 1);
end

function checkboxExpand_Spring_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U2, 'Value', 0);
    set(handles.checkboxExpand_Spring_U2, 'Value', 1);
end

function checkboxExpand_Spring_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_U3, 'Value', 0);
    set(handles.checkboxExpand_Spring_U3, 'Value', 1);
end

function checkboxExpand_Spring_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R1, 'Value', 0);
    set(handles.checkboxExpand_Spring_R1, 'Value', 1);
end

function checkboxExpand_Spring_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R2, 'Value', 0);
    set(handles.checkboxExpand_Spring_R2, 'Value', 1);
end

function checkboxExpand_Spring_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_R3, 'Value', 0);
    set(handles.checkboxExpand_Spring_R3, 'Value', 1);
end

function checkboxExpand_Spring_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Fixed_Align, 'Value', 0);
    set(handles.checkboxExpand_Spring_Align, 'Value', 1);
end

% Link Checkboxes -------------------------------------------------------

function checkboxLinkU1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_U1, 'Enable', 'off', 'String', get(handles.editFixed_Spring_U1, 'String'));
    set(handles.checkboxFixed_Spring_U1, 'Value', 1);
    set(handles.checkboxExpand_Spring_U1, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_U1, 'Value', 0);
    set(handles.checkboxExpand_Fixed_U1, 'Value', 0);
    set(handles.checkboxExpand_Update_U1, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{1,3} = Data{1,1};
    Data{1,4} = Data{1,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(1) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_U1, 'Enable', 'on');
    set(handles.checkboxExpand_Update_U1, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(1) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkU2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_U2, 'Enable', 'off', 'String', get(handles.editFixed_Spring_U2, 'String'));
    set(handles.checkboxFixed_Spring_U2, 'Value', 1);
    set(handles.checkboxExpand_Spring_U2, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_U2, 'Value', 0);
    set(handles.checkboxExpand_Fixed_U2, 'Value', 0);
    set(handles.checkboxExpand_Update_U2, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{2,3} = Data{2,1};
    Data{2,4} = Data{2,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(2) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_U2, 'Enable', 'on');
    set(handles.checkboxExpand_Update_U2, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(2) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkU3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_U3, 'Enable', 'off', 'String', get(handles.editFixed_Spring_U3, 'String'));
    set(handles.checkboxFixed_Spring_U3, 'Value', 1);
    set(handles.checkboxExpand_Spring_U3, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_U3, 'Value', 0);
    set(handles.checkboxExpand_Fixed_U3, 'Value', 0);
    set(handles.checkboxExpand_Update_U3, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{3,3} = Data{3,1};
    Data{3,4} = Data{3,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(3) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_U3, 'Enable', 'on');
    set(handles.checkboxExpand_Update_U3, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(3) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkR1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_R1, 'Enable', 'off', 'String', get(handles.editFixed_Spring_R1, 'String'));
    set(handles.checkboxFixed_Spring_R1, 'Value', 1);
    set(handles.checkboxExpand_Spring_R1, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_R1, 'Value', 0);
    set(handles.checkboxExpand_Fixed_R1, 'Value', 0);
    set(handles.checkboxExpand_Update_R1, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{4,3} = Data{4,1};
    Data{4,4} = Data{4,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(4) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_R1, 'Enable', 'on');
    set(handles.checkboxExpand_Update_R1, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(4) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkR2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_R2, 'Enable', 'off', 'String', get(handles.editFixed_Spring_R2, 'String'));
    set(handles.checkboxFixed_Spring_R2, 'Value', 1);
    set(handles.checkboxExpand_Spring_R2, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_R2, 'Value', 0);
    set(handles.checkboxExpand_Fixed_R2, 'Value', 0);
    set(handles.checkboxExpand_Update_R2, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{5,3} = Data{5,1};
    Data{5,4} = Data{5,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(5) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_R2, 'Enable', 'on');
    set(handles.checkboxExpand_Update_R2, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(5) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkR3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_R3, 'Enable', 'off', 'String', get(handles.editFixed_Spring_R3, 'String'));
    set(handles.checkboxFixed_Spring_R3, 'Value', 1);
    set(handles.checkboxExpand_Spring_R3, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_R3, 'Value', 0);
    set(handles.checkboxExpand_Fixed_R3, 'Value', 0);
    set(handles.checkboxExpand_Update_R3, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{6,3} = Data{6,1};
    Data{6,4} = Data{6,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(6) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_R3, 'Enable', 'on');
    set(handles.checkboxExpand_Update_R3, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(6) = 0;
    setappdata(0,'Parameters',Parameters);
end

function checkboxLinkAlign_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.editExpand_Spring_Align, 'Enable', 'off', 'String', get(handles.editFixed_Spring_Align, 'String'));
    set(handles.checkboxFixed_Spring_Align, 'Value', 1);
    set(handles.checkboxExpand_Spring_Align, 'Value', 1, 'Enable', 'off');
    set(handles.checkboxFixed_Fixed_Align, 'Value', 0);
    set(handles.checkboxExpand_Fixed_Align, 'Value', 0);
    set(handles.checkboxExpand_Update_Align, 'Enable', 'off');
    
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{7,3} = Data{7,1};
    Data{7,4} = Data{7,2};
    set(handles.uitableAlphaValues, 'Data', Data);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(7) = 1;
    setappdata(0,'Parameters',Parameters);
else
    set(handles.editExpand_Spring_Align, 'Enable', 'on');
    set(handles.checkboxExpand_Update_Align, 'Enable', 'on');
    
    Parameters = getappdata(0,'Parameters');
    Parameters.Bearing.Linked(7) = 0;
    setappdata(0,'Parameters',Parameters);
end

% Update Checkboxes -------------------------------------------------------

function checkboxExpand_Update_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_U1, 'Value', 1);
    set(handles.checkboxExpand_Fixed_U1, 'Value', 0);
end

function checkboxExpand_Update_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_U2, 'Value', 1);
    set(handles.checkboxExpand_Fixed_U2, 'Value', 0);
end

function checkboxExpand_Update_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_U3, 'Value', 1);
    set(handles.checkboxExpand_Fixed_U3, 'Value', 0);
end

function checkboxExpand_Update_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_R1, 'Value', 1);
    set(handles.checkboxExpand_Fixed_R1, 'Value', 0);
end

function checkboxExpand_Update_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_R2, 'Value', 1);
    set(handles.checkboxExpand_Fixed_R2, 'Value', 0);
end

function checkboxExpand_Update_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_R3, 'Value', 1);
    set(handles.checkboxExpand_Fixed_R3, 'Value', 0);
end

function checkboxExpand_Update_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxExpand_Spring_Align, 'Value', 1);
    set(handles.checkboxExpand_Fixed_Align, 'Value', 0);
end

function checkboxFixed_Update_U1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_U1, 'Value', 1);
    set(handles.checkboxFixed_Fixed_U1, 'Value', 0);
end

if get(handles.checkboxLinkU1, 'Value')
    set(handles.checkboxExpand_Update_U1, 'Value', get(hObject, 'Value'));
end    

function checkboxFixed_Update_U2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_U2, 'Value', 1);
    set(handles.checkboxFixed_Fixed_U2, 'Value', 0);
end
    
if get(handles.checkboxLinkU2, 'Value')
    set(handles.checkboxExpand_Update_U2, 'Value', get(hObject, 'Value'));
end       
    
function checkboxFixed_Update_U3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_U3, 'Value', 1);
    set(handles.checkboxFixed_Fixed_U3, 'Value', 0);
end

if get(handles.checkboxLinkU3, 'Value')
    set(handles.checkboxExpand_Update_U3, 'Value', get(hObject, 'Value'));
end    

function checkboxFixed_Update_R1_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_R1, 'Value', 1);
    set(handles.checkboxFixed_Fixed_R1, 'Value', 0);
end

if get(handles.checkboxLinkR1, 'Value')
    set(handles.checkboxExpand_Update_R1, 'Value', get(hObject, 'Value'));
end    

function checkboxFixed_Update_R2_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_R2, 'Value', 1);
    set(handles.checkboxFixed_Fixed_R2, 'Value', 0);
end

if get(handles.checkboxLinkR2, 'Value')
    set(handles.checkboxExpand_Update_R2, 'Value', get(hObject, 'Value'));
end    

function checkboxFixed_Update_R3_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_R3, 'Value', 1);
    set(handles.checkboxFixed_Fixed_R3, 'Value', 0);
end

if get(handles.checkboxLinkR3, 'Value')
    set(handles.checkboxExpand_Update_R3, 'Value', get(hObject, 'Value'));
end    

function checkboxFixed_Update_Align_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkboxFixed_Spring_Align, 'Value', 1);
    set(handles.checkboxFixed_Fixed_Align, 'Value', 0);
end

if get(handles.checkboxLinkAlign, 'Value')
    set(handles.checkboxExpand_Update_Align, 'Value', get(hObject, 'Value'));
end    

% Spring Values -----------------------------------------------------------

function editFixed_Spring_U1_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkU1, 'Value')
    set(handles.editExpand_Spring_U1, 'String', get(hObject, 'String'));
end

function editFixed_Spring_U2_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkU2, 'Value')
    set(handles.editExpand_Spring_U2, 'String', get(hObject, 'String'));
end

function editFixed_Spring_U3_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkU3, 'Value')
    set(handles.editExpand_Spring_U3, 'String', get(hObject, 'String'));
end

function editFixed_Spring_R1_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkR1, 'Value')
    set(handles.editExpand_Spring_R1, 'String', get(hObject, 'String'));
end

function editFixed_Spring_R2_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkR2, 'Value')
    set(handles.editExpand_Spring_R2, 'String', get(hObject, 'String'));
end

function editFixed_Spring_R3_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkR3, 'Value')
    set(handles.editExpand_Spring_R3, 'String', get(hObject, 'String'));
end

function editFixed_Spring_Align_Callback(hObject, eventdata, handles)
if get(handles.checkboxLinkAlign, 'Value')
    set(handles.editExpand_Spring_Align, 'String', get(hObject, 'String'));
end

function editExpand_Spring_U1_Callback(hObject, eventdata, handles)

function editExpand_Spring_U2_Callback(hObject, eventdata, handles)

function editExpand_Spring_U3_Callback(hObject, eventdata, handles)

function editExpand_Spring_R1_Callback(hObject, eventdata, handles)

function editExpand_Spring_R2_Callback(hObject, eventdata, handles)

function editExpand_Spring_R3_Callback(hObject, eventdata, handles)

function editExpand_Spring_Align_Callback(hObject, eventdata, handles)

% - uitable ------------------------------------------------------------
function uitableAlphaValues_CellEditCallback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

row = eventdata.Indices(1); % DOF
column = eventdata.Indices(2); % min or max

if Parameters.Bearing.Linked(row)
    Data = get(handles.uitableAlphaValues, 'Data');
    Data{row,column+2} = eventdata.NewData;
    set(handles.uitableAlphaValues, 'Data', Data);
end


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
