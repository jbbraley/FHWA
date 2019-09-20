function varargout = SteelGirderRAMPS_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SteelGirderRAMPS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SteelGirderRAMPS_gui_OutputFcn, ...
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

% Opening/Closing Functions -----------------------------------------------
function SteelGirderRAMPS_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% DO NOT EDIT ABOVE THIS LINE--------------------------------------

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Assign model build method
Parameters.ModelType = 'RAMPS Design';

% Set guis handles
Options.handles.guiBuildRAMPSModel = hObject;

% Show Beam Picture
axes(handles.axisBeamPicture);
old = cd('../');
imshow([pwd '\Img\BeamSection.jpg']);
cd(old);

% --------------------- Fields and Checkboxes -----------------------

% Composite Action
Parameters.Deck.CompositeDesign = 1;

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
%             set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
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
%             set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
            set(handles.radiobtnDesign_LRFD, 'Value', 1, 'enable', 'inactive');
            
            set(handles.popupDesignTruck, 'String', {'HL-93'});
            set(handles.popupDesignTruck, 'Value', 1);
        end
        
        Parameters.Design.DesignLoad = 'A';
    
         % Truck Loads
        Parameters.Design = GetTruckLoads(Parameters.Design);
    end
end

% Default design code
set(handles.radiobtnDesign_LRFD, 'value', 1);
set(handles.popupDesignTruck, 'String', {'HL-93'});
set(handles.popupDesignTruck, 'Value', 1);
Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';

% Set Table Dims & Properties
set(handles.tableInputs, 'ColumnWidth', {180, 95});
editable = [false, true];
set(handles.tableInputs, 'ColumnEditable', editable);

% Fill table data
if Parameters.Spans ==1
    inputs = cell(4,2);
    outputs = cell(4,2);
    inputs(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';'Web Thickness [in]'};
    outputs(:,1) = {'Girder Chosen'; 'Positive Capacity [lb-in]'; 'Moment of Inertia, Ix [in^4]'; 'Section Area [in^2]'};
    if strcmp(Parameters.Dia.Assign, 'Auto')
       outputs(end+1,1) = {'Dia Section'};
    end
    if isappdata(0, 'P_Temp3')
        inputs(:,2) = {Parameters.Beam.d; Parameters.Beam.bf; Parameters.Beam.tf; Parameters.Beam.tw};
        if strcmp(Parameters.Dia.Assign, 'Auto')
           outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos, Parameters.Beam.I.Ix, Parameters.Beam.A; Parameters.Dia.SectionName};  
        else
           outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos, Parameters.Beam.I.Ix, Parameters.Beam.A}; 
        end               
    end
    
else
    inputs = cell(6,2);
    outputs = cell(7,2);
    inputs(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';...
    'Web Thickness [in]'; 'Cover Plate Length [in]'; 'Cover Plate Thickness [in]'};
    outputs(:,1) = {'Girder Chosen'; 'Positive Capacity [lb-in]'; 'Negative Capacity [psi]'; 'Positive Ix [in^4]'; 'Negative Ix [in^4]';...
        'Positive Section Area [in^2]'; 'Negative Section Area [in^2]'};
    if strcmp(Parameters.Dia.Assign, 'Auto')
        outputs(end+1,1) = {'Dia Section'};
    end
    if isappdata(0, 'P_Temp3')
       inputs(:,2) = {Parameters.Beam.d; Parameters.Beam.bf; Parameters.Beam.tf; Parameters.Beam.tw;...
                Parameters.Beam.CoverPlate.Length; Parameters.Beam.CoverPlate.t};
        if Parameters.Beam.CoverPlate.t > 0
            if strcmp(Parameters.Dia.Assign, 'Auto')
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.CoverPlate.I.Ix; Parameters.Beam.A; Parameters.Beam.CoverPlate.A; Parameters.Dia.SectionName};
            else
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.CoverPlate.I.Ix; Parameters.Beam.A; Parameters.Beam.CoverPlate.A};
            end           
        else
            if strcmp(Parameters.Dia.Assign, 'Auto')
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.I.Ix; Parameters.Beam.A; Parameters.Beam.A; Parameters.Dia.SectionName}; 
            else
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.I.Ix; Parameters.Beam.A; Parameters.Beam.A}; 
            end           
        end
    end
end
 
set(handles.tableInputs, 'Data', inputs);
set(handles.tableOutputs, 'Data', outputs);

% Cover plate
if Parameters.Spans == 1
    set(handles.editCoverPlateDesignLength, 'Value', 0, 'enable', 'off');
    set(handles.checkboxCoverPlate, 'enable', 'off');
    Parameters.Beam.CoverPlate.Ratio = 0;
end

% Set app data
% Options.handles.guiBuildRAMPSModel = handles.guiBuildRAMPSModel;
setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Save temporary Parameters
opening_P = Parameters;
setappdata(0, 'opening_P', opening_P);

% Update handles structure
guidata(hObject, handles);

function guiBuildRAMPSModel_CloseRequestFcn(hObject, eventdata, handles)
try
    Options = getappdata(0,'Options');
    Options.handles = rmfield(Options.handles,'guiBuildRAMPSModel');
    setappdata(0,'Options',Options);
catch
end

delete(hObject);

function varargout = SteelGirderRAMPS_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% Creation Functions ------------------------------------------------------
function NotBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textOutToOutWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCoverPlateDesignLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCoverPlateDesignLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupDesignTruck_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editMaxSpantoDepth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNumGirder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editGirderSpacing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textTotalWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textTotalWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textOverhang_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function axisBeamPicture_CreateFcn(hObject, eventdata, handles)

% Button/Checkbox Callbacks -----------------------------------------------

function checkboxCoverPlate_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 1
    set(handles.editCoverPlateDesignLength, 'enable', 'on');
else
    set(handles.editCoverPlateDesignLength, 'enable', 'inactive');
    set(handles.editCoverPlateDesignLength, 'string', '0');
end

function radiobtnDesign_ASD_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Design Codes
if get(hObject, 'value') == 1
    set(handles.radiobtnDesign_LRFD, 'Value', 0);
else
    set(handles.radiobtnDesign_ASD, 'value', 0);
end

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

function radiobtnDesign_LRFD_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Design Codes
if get(hObject, 'value') == 1
    set(handles.radiobtnDesign_ASD, 'Value', 0);
else
    set(handles.radiobtnDesign_LRFD, 'value', 0);
end

set(handles.popupDesignTruck, 'String', {'HL-93'});
set(handles.popupDesignTruck, 'Value', 1);

Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';

setappdata(0,'Parameters', Parameters);

% call truck list for the default truck
popupDesignTruck_Callback(handles.popupDesignTruck, eventdata, handles);

setappdata(0,'Parameters', Parameters);

function pushbtnRunDesign_Callback(hObject, eventdata, handles)
% Get app data
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

% Error checking
if ~get(handles.radiobtnDesign_LRFD, 'value') == 1 && ~get(handles.radiobtnDesign_ASD, 'value') == 1
    msgbox('Please select design code.', 'Design Code Error', 'error')
    return
end

% Error checking
if isnan(str2double(get(handles.editNumGirder, 'string'))) || isnan(str2double(get(handles.editGirderSpacing, 'string')))
    Parameters.NumGirder = 0;
    Parameters.GirderSpacing = 0;
else
   Parameters.NumGirder = str2double(get(handles.editNumGirder, 'string'));
   Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
end

% Get Girder Spacing Field and Compute Num Girder
Parameters.Design.MaxSpantoDepth = str2double(get(handles.editMaxSpantoDepth, 'String'));

if  Parameters.NumGirder < 1 || Parameters.GirderSpacing < 1
    msgbox('Please Assign Girder Number and Beam Spacing or Cancel', 'Missing Beam Information','error');
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
% cleat table data
inputs = get(handles.tableInputs, 'Data');
new_inputs = cell(size(inputs,1),size(inputs,2));
new_inputs(:,1) = inputs(:,1);
outputs = get(handles.tableOutputs, 'Data');
new_outputs = cell(size(outputs,1),size(outputs,2));
new_outputs(:,1) = outputs(:,1);
set(handles.tableInputs, 'Data', new_inputs);
set(handles.tableOutputs, 'Data', new_outputs);

if strcmp(Parameters.Geo, 'NBI')
    NBI = getappdata(0,'NBI');
else
    NBI = [];
end

% Cover plate length
if Parameters.Spans > 1
    if get(handles.checkboxCoverPlate, 'value') == 1
        Parameters.Beam.CoverPlate.Ratio = str2double(get(handles.editCoverPlateDesignLength, 'String'));
        Parameters.Beam.CoverPlate.Length = Parameters.Beam.CoverPlate.Ratio*max(Parameters.Length);
    else
        Parameters.Beam.CoverPlate.Ratio = 0;
        Parameters.Beam.CoverPlate.Length = 0;
        Parameters.Beam.CoverPlate.t = 0;
    end
else
    Parameters.Beam.CoverPlate.Ratio = 0;
    Parameters.Beam.CoverPlate.Length = 0;
    Parameters.Beam.CoverPlate.t = 0;
end

% Save current beam parameters to Interior and Exterior
Beam = Parameters.Beam;
Parameters.Beam.Int = Beam;
Parameters.Beam.Int.Designation = 'Interior';
Parameters.Beam.Ext = Beam;
Parameters.Beam.Ext.Designation = 'Exterior';

% Assign NumGirder and GirderSpacing
if ~isfield(Parameters, 'NumGirder')
    Parameters.NumGirder = str2double(get(handles.editNumGirder, 'string'));
    Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
    NumGirder = Parameters.NumGirder;
    GirderSpacing = Parameters.GirderSpacing;
else
    NumGirder = str2double(get(handles.editNumGirder, 'string'));
    GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
end

%Run Design
h = waitbar(0,'Please Wait While RAMPS Design is Executed...'); 

% Set Section Design
Parameters.Design.Section = 'Interior/Exterior';

waitbar(.1,h, 'Finalizing Structure Configuration');
Parameters = GetStructureConfig(NBI, Parameters, [], Options);
waitbar(.2,h, 'Getting AASHTO Design Parameters');
Parameters = AASHTODesign(Parameters);
waitbar(.5,h, 'Calculating Line Girder Member Actions');
if ~isfield(Parameters.Design, 'Load')
    Parameters = GetMemberActions(Parameters);
elseif Parameters.NumGirder ~= NumGirder || Parameters.GirderSpacing ~= GirderSpacing
    Parameters.NumGirder = NumGirder;
    Parameters.GirderSpacing = GirderSpacing;
    Parameters = GetMemberActions(Parameters);
end
waitbar(.55,h,'Calculation Live Load Deflections');
Parameters = GetAASHTOLLDeflectionRequirement(Parameters);
waitbar(.7,h, 'Optimizing Plate Girder Section');
inputs{1} = 'RAMPS';
Parameters = GirderSizing(Parameters, Options, inputs);


% Set Values to Beam
if ~strcmp(Parameters.Beam.Type, 'None')
    
    cell_listbox = {get(handles.NotBox, 'string')};
    length_cell_listbox = length(cell_listbox);
    
    msg{1} = 'RAMPS Design Complete...';
    msg{2} = 'Design Summary:';
    msg{3} = Parameters.Beam.Type;
    if strcmp(Parameters.Design.Code, 'LRFD')
        if Parameters.Beam.Comp == 1 
            msg{4} = 'Compact Design.';    
        elseif Parameters.Beam.Comp == 2 
            msg{4} = 'Non-Compact Design.';
        end
        
        if strcmp(Parameters.Beam.Type, 'Plate')
            if all(Parameters.Beam.Constraints <= 0)
                msg{5} = 'All contraints pass.';
            else
                msg{5} = 'Constraints do not pass.';
            end        
        end
        
    end
    
    for ii = 1:length(msg)
        cell_listbox{length_cell_listbox +ii} = msg{ii};
        set(handles.NotBox, 'string', cell_listbox);
        set(handles.NotBox, 'Value', length_cell_listbox +ii);
    end
    
    % Fill table data
    if Parameters.Spans == 1
        inputs(:,2) = {Parameters.Beam.d;Parameters.Beam.bf;Parameters.Beam.tf;Parameters.Beam.tw};
        if strcmp(Parameters.Dia.Assign, 'Auto')
            outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.I.Ix; Parameters.Beam.A; Parameters.Dia.SectionName};
        else
            outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.I.Ix; Parameters.Beam.A};
        end
    else
        inputs(:,2) = {Parameters.Beam.d;Parameters.Beam.bf;Parameters.Beam.tf;...
        Parameters.Beam.tw;Parameters.Beam.CoverPlate.Length;Parameters.Beam.CoverPlate.t};
        if Parameters.Beam.CoverPlate.t > 0
            if strcmp(Parameters.Dia.Assign, 'Auto')
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
                   Parameters.Beam.CoverPlate.I.Ix; Parameters.Beam.A; Parameters.Beam.CoverPlate.A; Parameters.Dia.SectionName};
            else
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
                   Parameters.Beam.CoverPlate.I.Ix; Parameters.Beam.A; Parameters.Beam.CoverPlate.A};
            end
           
        else
            if strcmp(Parameters.Dia.Assign, 'Auto')
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.I.Ix; Parameters.Beam.A; Parameters.Beam.A;Parameters.Dia.SectionName};
            else
                outputs(:,2) = {Parameters.Beam.Designation; Parameters.Beam.Mn_pos; Parameters.Beam.Fn_neg; Parameters.Beam.I.Ix;...
               Parameters.Beam.I.Ix; Parameters.Beam.A; Parameters.Beam.A};
            end
            
        end
    end

    
    set(handles.tableInputs, 'Data', inputs);
    set(handles.tableOutputs, 'Data', outputs);
   
else
    set(handles.tableInputs, 'Data', new_inputs);
    set(handles.tableOutputs, 'Data', new_outputs);
    
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

close(h);

% setappdata(0, 'P_temp', P_temp);
setappdata(0, 'Parameters', Parameters);
setappdata(0, 'Options', Options);

% LRFD Assignments
Parameters.Rating.Code = 'LRFD';
Parameters.Rating.DesignLoad = 'A';
% Get Trucks
Parameters.Rating = GetTruckLoads(Parameters.Rating);
Parameters.Rating.IMF = 1.33;
Parameters.Rating.Load.A = Parameters.Rating.Load.A*Parameters.Rating.IMF;
Parameters.Rating.Load.TD = Parameters.Rating.Load.TD*Parameters.Rating.IMF;
% AASHTO Load Rating
Parameters = AASHTOLoadRating(Parameters);
Parameters.Rating.SingleLine = GetRatingFactor(Parameters.Beam,Parameters.Demands,Parameters,'false');
keyboard;

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

if isappdata(0, 'count')
    count = getappdata(0, 'count');
end

para = get(handles.tableInputs, 'Data');

%Assign manual input dimensions
newpara = get(handles.tableInputs, 'Data');
if Parameters.Spans == 1
    newpara = cell2mat(newpara(1:4,2));
    oldpara = [Parameters.Beam.d;Parameters.Beam.bf;Parameters.Beam.tf;...
    Parameters.Beam.tw];
else
    newpara = cell2mat(newpara(1:6,2));
    oldpara = [Parameters.Beam.d;Parameters.Beam.bf;Parameters.Beam.tf;...
    Parameters.Beam.tw; Parameters.Beam.CoverPlate.Length;Parameters.Beam.CoverPlate.t];
end

if ~all(newpara == oldpara)
  
    Parameters.ModelType = 'RAMPS Design (Altered)';
    Parameters.Beam.Designation = 'Manual Asssign';
    
    if get(handles.radiobtnDesign_LRFD, 'Value') == 1
       Parameters.Design.Code = 'LRFD';
       Parameters.Design.DesignLoad = 'A'; 
    elseif get(handles.radiobtnDesign_ASD, 'value') == 1
       Parameters.Design.Code = 'ASD';
       Parameters.Design.DesignLoad = '6';
    end
    
    % Assign field values to parameters
    Parameters.Beam.d = para{1,2};
    Parameters.Beam.bf = para{2,2};
    Parameters.Beam.tf = para{3,2};
    Parameters.Beam.tw = para{4,2};
    
    if Parameters.Spans > 1
        Parameters.Beam.CoverPlate.Length = para{5,2};
        Parameters.Beam.CoverPlate.t = para{6,2};
        Parameters.Beam.CoverPlate.Ratio = Parameters.Beam.CoverPlate.Length*max(Parameters.Length);
        if Parameters.Beam.CoverPlate.t > 0
            Parameters.Beam.CoverPlate.bf = Parameters.Beam.bf;
            Parameters.Beam.CoverPlate.tf = Parameters.Beam.tf + Parameters.Beam.CoverPlate.t;
            Parameters.Beam.CoverPlate.tw = Parameters.Beam.tw;
            Parameters.Beam.CoverPlate.d = Parameters.Beam.d + 2*Parameters.Beam.CoverPlate.t;
        end               
    end
    
% Recalculate properties, forces, and capacity for parameters
    [Parameters, Parameters.Beam] = GetSectionProperties(Parameters.Beam, Parameters);
    [Parameters, ArgOut] = GetSectionForces(Parameters.Beam, Parameters);
    Parameters.Demands.LRFD = ArgOut.LRFD;
    Parameters.Demands.DeadLoad = ArgOut.DeadLoad;
    Parameters.Demands.LiveLoad = ArgOut.LiveLoad;
    Parameters.Beam = GetLRFDResistance(Parameters.Beam, Parameters.Demands, Parameters);
    fields = {'StartPoints','x','Iterations','DesignTime', 'Constraints'};
    Parameters.Beam = rmfield(Parameters.Beam,fields);
    Parameters.Beam.Constraints = LRFDConstraintCheck(Parameters);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    if Parameters.Beam.CoverPlate.t > 0     
        Parameters.Beam.CoverPlate.Section = Parameters.Beam.Section;
        Parameters.Beam.CoverPlate.Section(3) = Parameters.Beam.CoverPlate.d;
        Parameters.Beam.CoverPlate.Section(4) = Parameters.Beam.CoverPlate.tf; % Beam w/ cover plate section geometry
        Parameters.Beam.CoverPlate.Section(5) = Parameters.Beam.CoverPlate.tf;
    end
end

% Error checking
% if isnan(Parameters.Beam.d) || isnan(Parameters.Beam.bf) ||...
%         isnan(Parameters.Beam.tf) || isnan(Parameters.Beam.tw)
%     msgbox('Please Assign Beam Section or Cancel', 'Missing Beam Section','error');
%     return
% end

if ~all(Parameters.Beam.Constraints <= 0)
    if ~isappdata(0, 'count')
        count = 1;
        setappdata(0, 'count', count);
        msgbox('Current member size does not meet AASHTO LRFD Design Specifications', 'Member Size Error', 'error')    
        return
    elseif count == 1;
    end 
end

if isnan(Parameters.GirderSpacing) || isnan(Parameters.NumGirder)
    msgbox('Please Assign Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
end

if isfield(Parameters.Beam, 'CoverPlate')
    if Parameters.Beam.CoverPlate.t > 2*Parameters.Beam.tf
        msgbox('Cover plate is larger than twice the flange thickness', 'Cover Plate Design Error', 'error')
    end
end

% Save temprary parameters up to this point
P_Temp3 = Parameters;
setappdata(0, 'P_Temp3', P_Temp3);
rmappdata(0,'opening_P');

setappdata(0,'Parameters',Parameters);
set(handles.guiBuildRAMPSModel, 'Visible', 'off');

function pushbtnClear_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'opening_P');

% Clear Tables
inputs = get(handles.tableInputs, 'Data');
new_inputs = cell(size(inputs,1),size(inputs,2));
new_inputs(:,1) = inputs(:,1);
outputs = get(handles.tableOutputs, 'Data');
new_outputs = cell(size(outputs,1),size(outputs,2));
new_outputs(:,1) = outputs(:,1);
set(handles.tableInputs, 'Data', new_inputs);
set(handles.tableOutputs, 'Data', new_outputs);

set(handles.editGirderSpacing, 'string', '');
set(handles.editNumGirder, 'string', '');
set(handles.textTotalWidth, 'string','');
set(handles.textOverhang,'string','');

if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end

set(handles.NotBox, 'value', 1, 'string', {''});
setappdata(0, 'Parameters', Parameters);

function pushbtnCancel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_Temp2');
setappdata(0, 'Parameters', Parameters);
if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end
guiBuildRAMPSModel_CloseRequestFcn(handles.guiBuildRAMPSModel, eventdata, handles)

% Input Callbacks ---------------------------------------------------------

function editCoverPlateDesignLength_Callback(hObject, eventdata, handles)

function popupDesignTruck_Callback(hObject, eventdata, handles)

function editMaxSpantoDepth_Callback(hObject, eventdata, handles)

function editNumGirder_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.NumGirder = str2num(get(hObject, 'String'));

if strcmp(Parameters.Geo,'NBI')
    set(handles.editGirderSpacing, 'String', ceil(Parameters.Width/Parameters.NumGirder)); % round to nearest inch
end

if ~isempty(get(handles.editGirderSpacing, 'String')) 
    set(handles.textTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
    set(handles.textOverhang, 'string', (str2double(get(handles.textOutToOutWidth, 'string'))...
        -str2double(get(handles.textTotalWidth, 'string')))/2);
end

function editGirderSpacing_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.editNumGirder, 'String')) 
    set(handles.textTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
    set(handles.textOverhang, 'string', (str2double(get(handles.textOutToOutWidth, 'string'))...
        -str2double(get(handles.textTotalWidth, 'string')))/2);
end

% Output Callbacks --------------------------------------------------------

function NotBox_Callback(hObject, eventdata, handles)

function textOutToOutWidth_Callback(hObject, eventdata, handles)

function textTotalWidth_Callback(hObject, eventdata, handles)

function textOverhang_Callback(hObject, eventdata, handles)
