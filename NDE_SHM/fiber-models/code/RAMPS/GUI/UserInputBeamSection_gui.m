% 10/2/2014 (NPR): Removed Wearing surface from GUI and made all elements
% "normalized" in order to allow for resizing on other platforms

% (10/20/2014) NPR: Updated to reflect manual or RAMPS design


function varargout = UserInputBeamSection_gui(varargin)
% Last Modified by GUIDE v2.5 21-Oct-2014 11:55:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputBeamSection_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputBeamSection_gui_OutputFcn, ...
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


% --- Executes just before UserInputBeamSection_gui is made visible.
function UserInputBeamSection_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInputBeamSection_gui (see VARARGIN)

% Choose default command line output for UserInputBeamSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Set guis handles
Options.handles.guiUserInputBeamSection = hObject;

% % Center and Position
% % pixels
% set(handles.guiUserInputBeamSection, 'Units', 'pixels' );
% 
% % get your display size
% screenSize = get(0, 'ScreenSize');
% 
% % calculate the center of the display
% position = get(handles.guiUserInputBeamSection,'Position');
% position(1) = (screenSize(3)-position(3))/2;
% position(2) = (screenSize(4)-position(4))/2;
% 
% % center the window
% set(handles.guiUserInputBeamSection, 'Position', position);

% Show Beam Picture
axes(handles.axisBeamPicture);
old = cd('../');
imshow([pwd '\Img\BeamSection.jpg']);
cd(old);

% --------------------- Fields and Checkboxes ----------------------------
% Set List Box Inital Value to 0
set(handles.listboxBeamSection,'Value',1);

% List Box
old = cd('../');
load([pwd '\Tables\AISCShapes_Current.mat']);
cd(old);

setappdata(0,'AISCShape',AISCShape);
Shapelist = cell(56,1,275);
Shapelist(:,1,2:end) = struct2cell(AISCShape(1:274));
Shapelist(2,1,1) = {'Plate Girder Section'};
set(handles.listboxBeamSection, 'String', Shapelist(2,:));

% Set inital design code to none in case beam is chosen manually
Parameters.Design.Code = 'None';

% Composite Action
set(handles.checkboxComposite_Deck, 'Value', 1);
Parameters.Deck.CompositeDesign = 1;

% Design Buttons
set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');

% Span to Depth
set(handles.editMaxSpantoDepth, 'String', 20);

% Total width
set(handles.textOutToOutWidth, 'String', Parameters.Width);

% Cover plate length
set(handles.editCoverPlateDesignLength, 'String', Options.Default.CoverPlateLength);

% Set girder spacing to inactive if NBI data is applies
if strcmp(Parameters.Geo,'NBI')
    set(handles.editGirderSpacing, 'enable', 'off');
end

% Set Design Code and Design Truck
if isfield(Parameters, 'NBI')
    if ~isempty(Parameters.NBI)
        if strcmp(Parameters.NBI.DesignCode, 'ASD')
            % Design Codes
            set(handles.radiobtnDesign_ASD, 'Value', 1, 'enable', 'inactive');
            set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
            set(handles.radiobtnDesign_LRFD, 'Value', 0, 'enable', 'on');
            
            % Design Trucks
            tempcd = pwd;
            cd('../');
            load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
            cd(tempcd);
            
            set(handles.popupDesignTruck, 'String', DesignTruckList);
            
            if str2double(Parameters.NBI.DesignLoad) >= 1 && str2double(Parameters.NBI.DesignLoad) <= 6
                set(handles.popupDesignTruck, 'Value', str2double(Parameters.NBI.DesignLoad));
            else
                set(handles.popupDesignTruck, 'Value', 6);
            end
            
            Parameters.Design.DesignLoad = '6';
            Parameters.Design.Code = 'ASD';
        else
            % Design Codes
            set(handles.radiobtnDesign_ASD, 'Value', 0, 'enable', 'on');
            set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
            set(handles.radiobtnDesign_LRFD, 'Value', 1, 'enable', 'inactive');
            
            set(handles.popupDesignTruck, 'String', {'HL-93'});
            set(handles.popupDesignTruck, 'Value', 1);
        end
        
        Parameters.Design.DesignLoad = 'A';
    
         % Truck Loads
        Parameters.Design = GetTruckLoads(Parameters.Design);
    end
end

% Cover plate
if Parameters.Spans == 1
    set(handles.editCoverPlateDesignLength, 'Value', 0, 'enable', 'off');
    set([handles.editCoverPlateLength, handles.editCoverPlateThickness], 'Value', 0, 'enable', 'off');
    set([handles.CPradiobutton, handles.NoCPradiobutton, handles.CPRatiotext, handles.text40], 'enable', 'off');
    Parameters.Design.CoverPlate.Ratio = 0;
else
    set([handles.CPradiobutton, handles.NoCPradiobutton], 'enable', 'on');
end

%Assign initial Model type (NA, RAMPS Design, manual)
Parameters.ModelType = 'NA';

% Set app data
Options.handles.guiUserInputBeamSection = handles.guiUserInputBeamSection;
setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function varargout = UserInputBeamSection_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% ------------------------------------ Listbox ---------------------------
function listboxBeamSection_Callback(hObject, eventdata, handles)
indBeamSection = get(handles.listboxBeamSection,'Value');

if indBeamSection == 1
    pushbtnClear_Callback(hObject, eventdata, handles);
else
    AISCShape = getappdata(0,'AISCShape');
    set(handles.editBeam_D, 'String', num2str(AISCShape(indBeamSection-1).d));
    set(handles.editBeam_B1, 'String', num2str(AISCShape(indBeamSection-1).bf));
    set(handles.editBeam_T1, 'String', num2str(AISCShape(indBeamSection-1).tf));
    set(handles.editBeam_T3, 'String', num2str(AISCShape(indBeamSection-1).tw));
end

% -------- Beam Dimension Edit Boxes -------------------------------------
function editBeam_T1_Callback(hObject, eventdata, handles)
set(handles.listboxBeamSection,'Value',1);

function editBeam_T3_Callback(hObject, eventdata, handles)
set(handles.listboxBeamSection,'Value',1);

function editBeam_D_Callback(hObject, eventdata, handles)
set(handles.listboxBeamSection,'Value',1);

function editBeam_B1_Callback(hObject, eventdata, handles)
set(handles.listboxBeamSection,'Value',1);

% -------------------------- Girder Options ------------------------------
function editGirderSpacing_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.editNumGirder, 'String')) 
    set(handles.txtTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
end

function editNumGirder_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.NumGirder = str2num(get(hObject, 'String'));

if strcmp(Parameters.Geo,'NBI')
    set(handles.editGirderSpacing, 'String', ceil(Parameters.Width/Parameters.NumGirder)); % round to nearest inch
end

if ~isempty(get(handles.editGirderSpacing, 'String')) 
    set(handles.txtTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
end

function editMaxSpantoDepth_Callback(hObject, eventdata, handles)

function txtTotalWidth_Callback(hObject, eventdata, handles)

% -------------------------- Composite -----------------------------------
function checkboxComposite_Deck_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.Deck.CompositeDesign = 1;

setappdata(0,'Parameters',Parameters);

function checkboxComposite_Sidewalk_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.Sidewalk.CompositeDesign = 1;

setappdata(0,'Parameters',Parameters);

function checkboxComposite_Barrier_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.Barrier.CompositeDesign = 1;

setappdata(0,'Parameters',Parameters);

% -------------------------- Design Code----------------------------------
function radiobtnDesign_ASD_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Design Codes
set(handles.radiobtnDesign_ASD, 'Value', 1, 'enable', 'inactive')
set(handles.radiobtnDesign_LRFD, 'Value', 0, 'enable', 'on');

% Design Trucks
tempcd = pwd;
cd('../');
load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
cd(tempcd);

set(handles.popupDesignTruck, 'String', DesignTruckList, 'Value', 6);

Parameters.Design.DesignLoad = '6';
Parameters.Design.Code = 'ASD';

setappdata(0,'Parameters', Parameters);

% call truck list for the default truck
popupDesignTruck_Callback(handles.popupDesignTruck, eventdata, handles);

setappdata(0,'Parameters', Parameters);


function radiobtnDesign_LFD_Callback(hObject, eventdata, handles)

function radiobtnDesign_LRFD_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Design Codes
set(handles.radiobtnDesign_ASD, 'Value', 0, 'enable', 'on')
set(handles.radiobtnDesign_LRFD, 'Value', 1, 'enable', 'inactive');

set(handles.popupDesignTruck, 'String', {'HL-93'});
set(handles.popupDesignTruck, 'Value', 1);

Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';

setappdata(0,'Parameters', Parameters);

% call truck list for the default truck
popupDesignTruck_Callback(handles.popupDesignTruck, eventdata, handles);

setappdata(0,'Parameters', Parameters);

% -------------------------- Run Design ----------------------------------
function pushbtnRunDesign_Callback(hObject, eventdata, handles)
% Get app data
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

%Save parameters up to this point
P_temp = Parameters;

if ~get(handles.radiobtnDesign_LRFD, 'value') == 1 && ~get(handles.radiobtnDesign_ASD, 'value') == 1
    msgbox('Please select design code.', 'Design Code Error', 'error')
    return
end

% Reset GUI when new design is being run.
% Notification panel
set(handles.NotBox, 'value', 1);
cell_listbox = get(handles.NotBox, 'string');
length_cell_listbox = length(cell_listbox);
msg = {'Executing RAMPS Design...'};
if length_cell_listbox > 0
    set(handles.NotBox, 'string', msg{1});
else
    set(handles.NotBox, 'string', msg{1});
end

% Clear previously designed dimensions
gui_handles = [handles.editBeam_D, handles.editBeam_B1, handles.editBeam_T1, handles.editBeam_T3,...
    handles.editCoverPlateThickness, handles.editCoverPlateLength, handles.textExitFlag_CP,...
    handles.textExitFlag_Rolled, handles.textExitFlag_Plate];
set(gui_handles, 'string', '');



if strcmp(Parameters.Geo, 'NBI')
    NBI = getappdata(0,'NBI');
else
    NBI = [];
end

% Assign model build method
Parameters.ModelType = 'RAMPS Design';

% Get Girder Spacing Field and Compute Num Girder
Parameters.NumGirder = str2double(get(handles.editNumGirder, 'String'));
Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'String'));
Parameters.Design.MaxSpantoDepth = str2double(get(handles.editMaxSpantoDepth, 'String'));

% Composite design
Parameters.Deck.CompositeDesign = get(handles.checkboxComposite_Deck, 'Value');

% Cover plate length
if Parameters.Spans > 1
    Parameters.Design.CoverPlate.Ratio = str2double(get(handles.editCoverPlateDesignLength, 'String'));
end


% Error checking
if isempty(Parameters.GirderSpacing) || isempty(Parameters.NumGirder)
    msgbox('Please Assign Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
end

%Run Design
h = waitbar(0,'Please Wait While RAMPS Design is Executed...'); 

Parameters = GetStructureConfig(NBI, Parameters, [], Options);
waitbar(.25,h);
Parameters = AASHTODesign(Parameters);
waitbar(.7,h);
Parameters = AASHTOGirderSizing(Parameters, Options);
waitbar(.9,h);


% Set Values to Beam
if ~strcmp(Parameters.Beam.Type, 'None')
    
    cell_listbox = {get(handles.NotBox, 'string')};
    length_cell_listbox = length(cell_listbox);
    
    msg{1} = 'RAMPS Design Complete...';
    msg{2} = 'Design Summary:';
    msg{3} = Parameters.Beam.Type;
    if strcmp(Parameters.Design.Code, 'LRFD')
        if Parameters.Beam.Comp == 1 && all(Parameters.Beam.Constraints <= 0)
            msg{4} = 'Compact Design.';
            msg{5} = 'All contraints pass.';
        elseif Parameters.Beam.Comp == 2 && all(Parameters.Beam.Constraints <= 0)
            msg{4} = 'Non-Compact Design.';
            msg{5} = 'Constraints do not pass.';
        end
    end
    
    for ii = 1:length(msg)
        cell_listbox{length_cell_listbox +ii} = msg{ii};
        set(handles.NotBox, 'string', cell_listbox);
        set(handles.NotBox, 'Value', length_cell_listbox +ii);
    end
    
    set(handles.editBeam_D, 'String', num2str(Parameters.Beam.d));
    set(handles.editBeam_B1, 'String', num2str(Parameters.Beam.bf));
    set(handles.editBeam_T1, 'String', num2str(Parameters.Beam.tf));
    set(handles.editBeam_T3, 'String', num2str(Parameters.Beam.tw));
    
    if Parameters.Design.CoverPlate.Ratio > 0
        set(handles.editCoverPlateThickness, 'String', num2str(Parameters.Beam.CoverPlate.tf-Parameters.Beam.tf));
        set(handles.editCoverPlateLength, 'String', num2str(max(Parameters.Beam.CoverPlate.Length)));
    else 
        set(handles.editCoverPlateThickness, 'String', '0');
        set(handles.editCoverPlateLength, 'String', '0');
    end
else
    set(handles.editBeam_D, 'String', []);
    set(handles.editBeam_B1, 'String', []);
    set(handles.editBeam_T1, 'String', []);
    set(handles.editBeam_T3, 'String', []);
    set(handles.editCoverPlateThickness, 'String', []);
    set(handles.editCoverPlateLength, 'String', []);
    
    msg{1} = 'No solution was found.';
    msg{2} = 'RAMPS exceeded maximum allowable design iterations.';
    msg{3} = 'Adjust bridge design, or run again.';
    
    set(handles.NotBox, 'value', 1);
    cell_listbox = {get(handles.NotBox, 'string')};
    length_cell_listbox = length(cell_listbox);
    
    for ii = 1:length(msg)
        cell_listbox{length_cell_listbox +ii} = msg{ii};
        set(handles.NotBox, 'string', cell_listbox);
        set(handles.NotBox, 'Value', length_cell_listbox +ii);
    end
end


set(handles.textExitFlag_CP, 'String', num2str(Parameters.Design.ExitFlags(3)));
set(handles.textExitFlag_Plate, 'String', num2str(Parameters.Design.ExitFlags(2)));
set(handles.textExitFlag_Rolled, 'String', num2str(Parameters.Design.ExitFlags(1)));

if strcmp(Parameters.Beam.Type,'Rolled')
    listSection = get(handles.listboxBeamSection,'string');
    indSection = find(not(cellfun('isempty', strfind(listSection, Parameters.Beam.SectionName))));
    set(handles.listboxBeamSection,'value',indSection);
else
    set(handles.listboxBeamSection,'Value',1);
end

close(h);

setappdata(0, 'P_temp', P_temp);
setappdata(0, 'Parameters', Parameters);
setappdata(0, 'Options', Options);

% -------------------------- Design Truck --------------------------------
function popupDesignTruck_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
Parameters = getappdata(0,'Parameters');

if strcmp(Parameters.Design.Code, 'ASD')
    Parameters.Design.DesignLoad = num2str(get(hObject,'Value'));
else
    Parameters.Design.DesignLoad = 'A';
end

% Truck Loads
Parameters.Design = GetTruckLoads(Parameters.Design);

setappdata(0,'Parameters',Parameters);

% -------------------------- Closing Functions and Buttons ---------------
function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

% Beam Section List
SectionInd = get(handles.listboxBeamSection,'Value');

if SectionInd == 1
    Parameters.Beam.Name = 'Custom Section';
    Parameters.Beam.Type = 'Plate';
else
    SectionList = get(handles.listboxBeamSection,'String');
    
    Parameters.Beam.Name = SectionList{SectionInd};
    Parameters.Beam.Type = 'Rolled';
end

Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'String'));
Parameters.NumGirder = str2double(get(handles.editNumGirder, 'String'));
Parameters.Beam.CoverPlate.t = str2double(get(handles.editCoverPlateThickness, 'String'));    
Parameters.Beam.CoverPlate.Length = str2double(get(handles.editCoverPlateLength, 'String'));

%Assign temporary parameters
if ~isappdata(0, 'P_temp')
    P_temp = Parameters;
else
    P_temp = getappdata(0, 'P_temp');
end

%Assign manual input dimensions
dims = [str2double(get(handles.editBeam_D, 'String'));str2double(get(handles.editBeam_B1, 'String'));...
    str2double(get(handles.editBeam_T1, 'String'));str2double(get(handles.editBeam_T3, 'String'))];

if strcmp(Parameters.ModelType, 'RAMPS Design') && all(dims == [Parameters.Beam.d; Parameters.Beam.bf; Parameters.Beam.tf; Parameters.Beam.tw])
else
    Parameters = P_temp;
    Parameters.ModelType = 'Manual';
    Parameters.Design.Code = 'None';
    Parameters.Design.DesignLoad = 'None';
    
    % Assign field values to parameters
    Parameters.Beam.d = str2double(get(handles.editBeam_D, 'String'));
    Parameters.Beam.bf = str2double(get(handles.editBeam_B1, 'String'));
    Parameters.Beam.tf = str2double(get(handles.editBeam_T1, 'String'));
    Parameters.Beam.tw = str2double(get(handles.editBeam_T3, 'String'));
    Parameters.Beam.ind = Parameters.Beam.d - 2*Parameters.Beam.tf;
    Parameters.Beam.A = Parameters.Beam.ind*Parameters.Beam.tw + 2*Parameters.Beam.tf*Parameters.Beam.bf;
    Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12+Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.ind/2+Parameters.Beam.tf/2)^2)...
            + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
    Parameters.Beam.Iy = 2*Parameters.Beam.tf*Parameters.Beam.bf^3/12+(Parameters.Beam.d-2*Parameters.Beam.tf)*Parameters.Beam.tw^3/12; %Moment of inertia of the entire steel section
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    
    % Cover plate
    cplength = str2double(get(handles.editCoverPlateLength, 'String'));
    cpthick = str2double(get(handles.editCoverPlateThickness, 'String')); 
    if cplength > 0 && cpthick > 0
        Parameters.Beam.CoverPlate.d = Parameters.Beam.d + 2*Parameters.Beam.CoverPlate.t;
        Parameters.Beam.CoverPlate.bf = Parameters.Beam.bf;
        Parameters.Beam.CoverPlate.tf = Parameters.Beam.tf + Parameters.Beam.CoverPlate.t;
        Parameters.Beam.CoverPlate.tw = Parameters.Beam.tw;
        Parameters.Beam.CoverPlate.ind = Parameters.Beam.ind;
        Parameters.Beam.CoverPlate.A = Parameters.Beam.CoverPlate.ind*Parameters.Beam.CoverPlate.tw + 2*Parameters.Beam.CoverPlate.tf*Parameters.Beam.CoverPlate.bf;
        Parameters.Beam.CoverPlate.Ix = 2*(Parameters.Beam.CoverPlate.bf*Parameters.Beam.CoverPlate.tf^3/12+Parameters.Beam.CoverPlate.bf*Parameters.Beam.CoverPlate.tf*...
            (Parameters.Beam.CoverPlate.ind/2+Parameters.Beam.CoverPlate.tf/2)^2)+ Parameters.Beam.CoverPlate.tw*Parameters.Beam.CoverPlate.ind^3/12;
        Parameters.Beam.CoverPlate.Iy = 2*Parameters.Beam.CoverPlate.tf*Parameters.Beam.CoverPlate.bf^3/12+(Parameters.Beam.CoverPlate.d-2*Parameters.Beam.CoverPlate.tf)*Parameters.Beam.CoverPlate.tw^3/12; %Moment of inertia of the entire steel section
        Parameters.Beam.CoverPlate.Section = [Parameters.Beam.CoverPlate.bf, Parameters.Beam.CoverPlate.bf, Parameters.Beam.CoverPlate.d,...
            Parameters.Beam.CoverPlate.tf, Parameters.Beam.CoverPlate.tf, Parameters.Beam.CoverPlate.tw];
    end
   
end



Parameters = GetStructureConfig([], Parameters, [], Options);    

% Error checking
if isnan(Parameters.Beam.d) || isnan(Parameters.Beam.bf) ||...
        isnan(Parameters.Beam.tf) || isnan(Parameters.Beam.tw)
    msgbox('Please Assign Beam Section or Cancel', 'Missing Beam Section','error');
    return
end

if isnan(Parameters.GirderSpacing) || isnan(Parameters.NumGirder)
    msgbox('Please Assign Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
end

if isfield(Parameters.Beam, 'CoverPlate')
    if Parameters.Beam.CoverPlate.t > 2*Parameters.Beam.tf
        msgbox('Cover plate cannot be larger than twice the flange thickness', 'Cover Plate Design Error', 'error')
        return
    end
end

setappdata(0,'Parameters',Parameters);
setappdata(0, 'P_temp', P_temp);
set(handles.guiUserInputBeamSection, 'Visible', 'off');


function pushbtnClear_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_temp');
set(handles.editBeam_D, 'String', '');
set(handles.editBeam_B1, 'String', '');
set(handles.editBeam_T1, 'String', '');
set(handles.editBeam_T3, 'String', '');
set(handles.editCoverPlateThickness, 'String', '');
set(handles.editCoverPlateLength, 'String', '');
set(handles.NotBox, 'value', 1, 'string', {''});
set([handles.textExitFlag_CP, handles.textExitFlag_Rolled, handles.textExitFlag_Plate], 'string', '');
setappdata(0, 'Parameters', Parameters);

function pushbtnCancel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_temp');
setappdata(0, 'Parameters', Parameters);
guiUserInputBeamSection_CloseRequestFcn(handles.guiUserInputBeamSection, eventdata, handles)

function guiUserInputBeamSection_CloseRequestFcn(hObject, eventdata, handles)
try
    Options = getappdata(0,'Options');
    Options.handles = rmfield(Options.handles,'guiUserInputBeamSection');
    setappdata(0,'Options',Options);
catch
end

delete(hObject);

function editCoverPlateThickness_Callback(hObject, eventdata, handles)

function editCoverPlateLength_Callback(hObject, eventdata, handles)

function editCoverPlateDesignLength_Callback(hObject, eventdata, handles)


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


% --- Executes on button press in CPradiobutton.
function CPradiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to CPradiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1
    set(handles.editCoverPlateDesignLength, 'enable', 'on');
    set([handles.editCoverPlateLength, handles.editCoverPlateThickness], 'enable', 'on');
    set(handles.NoCPradiobutton, 'value', 0);
else
    set(handles.editCoverPlateDesignLength, 'enable', 'off')
end

% --- Executes on button press in NoCPradiobutton.
function NoCPradiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to NoCPradiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'value') == 1
    set(handles.editCoverPlateDesignLength, 'enable', 'off');
    set([handles.editCoverPlateLength, handles.editCoverPlateThickness], 'Value', 0, 'enable', 'off');
    set(handles.CPradiobutton, 'value', 0);
    set(handles.editCoverPlateDesignLength, 'string', '0');
else
    return
end
