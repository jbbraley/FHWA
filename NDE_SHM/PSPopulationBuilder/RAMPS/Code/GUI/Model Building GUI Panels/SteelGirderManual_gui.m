function varargout = SteelGirderManual_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SteelGirderManual_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SteelGirderManual_gui_OutputFcn, ...
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

function SteelGirderManual_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% DO NOT EDIT ABOVE THIS LINE--------------------------------------

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Assign model build method
Parameters.ModelType = 'Manual';

% Set guis handles
Options.handles.guiBuildManualModel = hObject;

% Show Beam Picture
axes(handles.axisBeamPicture);
old = cd('../');
imshow([pwd '\Img\BeamSection.jpg']);
cd(old);

% --------------------- Fields and Checkboxes -----------------------

% Set inital design code to none in case beam is chosen manually
Parameters.Design.Code = 'None';

% Composite Action
Parameters.Deck.CompositeDesign = 1;

% Total width
set(handles.textOutToOutWidth, 'String', Parameters.Width);

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
set([handles.tableInputs, handles.tableOutputs], 'ColumnWidth', {180, 95, 95});
editable = [false, true, true];
set(handles.tableInputs, 'ColumnEditable', editable);

% Fill table data
if Parameters.Spans ==1
    inputs = cell(4,3);
    outputs = cell(4,3);
    inputs(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';...
    'Web Thickness [in]'};
    if strcmp(Parameters.Dia.Assign, 'Auto')
        outputs(:,1) = {'Positive Capacity [lb-in]'; 'Moment of Inertia, Ix [in^4]'; 'Section Area [in^2]'; 'Dia Section'};
    else
        outputs(:,1) = {'Positive Capacity [lb-in]'; 'Moment of Inertia, Ix [in^4]'; 'Section Area [in^2]'};
    end
    if isappdata(0, 'P_Temp3')
        set(handles.editNumGirder, 'string', Parameters.NumGirder);
        set(handles.editGirderSpacing, 'string', Parameters.GirderSpacing);
        set(handles.textOverhang,'string', Parameters.Overhang);
        set(handles.textTotalWidth,'string',((Parameters.NumGirder-1)*Parameters.GirderSpacing));
        inputs(:,2) = {Parameters.Beam.Int.d; Parameters.Beam.Int.bf; Parameters.Beam.Int.tf; Parameters.Beam.Int.tw};
        inputs(:,3) = {Parameters.Beam.Ext.d; Parameters.Beam.Ext.bf; Parameters.Beam.Ext.tf; Parameters.Beam.Ext.tw};
        if strcmp(Parameters.Dia.Assign, 'Auto')
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Dia.SectionName};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Dia.SectionName};
        else
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A};
        end        
    else
        Parameters.ModelType ='None';
    end
else
    inputs = cell(6,3);
    outputs = cell(7,3);
    inputs(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';...
    'Web Thickness [in]'; 'Cover Plate Length [in]'; 'Cover Plate Thickness [in]'};
    if strcmp(Parameters.Dia.Assign, 'Auto')
        outputs(:,1) = {'Positive Capacity [lb-in]';'Negative Capacity [psi]'; 'Positive Ix [In^4]'; 'Negative Ix [in^4]';...
            'Positive Section Area [in^2]';'Negative Section Area [in^2]'; 'Dia Section'};
    else
        outputs(:,1) = {'Positive Capacity [lb-in]';'Negative Capacity [psi]'; 'Positive Ix [In^4]'; 'Negative Ix [in^4]';...
            'Positive Section Area [in^2]';'Negative Section Area [in^2]'};
    end
    if isappdata(0, 'P_Temp3')
        set(handles.editNumGirder, 'string', Parameters.NumGirder);
        set(handles.editGirderSpacing, 'string', Parameters.GirderSpacing);
        set(handles.textOverhang,'string', Parameters.Overhang);
        set(handles.textTotalWidth,'string',((Parameters.NumGirder-1)*Parameters.GirderSpacing));
        inputs(:,2) = {Parameters.Beam.Int.d; Parameters.Beam.Int.bf; Parameters.Beam.Int.tf; Parameters.Beam.Int.tw;...
            Parameters.Beam.Int.CoverPlate.Length; Parameters.Beam.Int.CoverPlate.t};
        inputs(:,3) = {Parameters.Beam.Ext.d; Parameters.Beam.Ext.bf; Parameters.Beam.Ext.tf; Parameters.Beam.Ext.tw;...
            Parameters.Beam.Ext.CoverPlate.Length; Parameters.Beam.Ext.CoverPlate.t};
        if strcmp(Parameters.Dia.Assign, 'Auto')
            if Parameters.Beam.CoverPlate.t > 0
                outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                    Parameters.Beam.Int.CoverPlate.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.CoverPlate.A; Parameters.Dia.SectionName};
                outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                    Parameters.Beam.Ext.CoverPlate.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.CoverPlate.A; Parameters.Dia.SectionName};
            else
                outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                    Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.A; Parameters.Dia.SectionName};
                outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                    Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.A; Parameters.Dia.SectionName};
            end
        else
            if Parameters.Beam.CoverPlate.t > 0
                outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                    Parameters.Beam.Int.CoverPlate.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.CoverPlate.A};
                outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                    Parameters.Beam.Ext.CoverPlate.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.CoverPlate.A};
            else
                outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                    Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.A};
                outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                    Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.A};
            end
        end
    else
        Parameters.ModelType ='None';
    end
end
 
set(handles.tableInputs, 'Data', inputs);
set(handles.tableOutputs, 'Data', outputs);

% Set app data
Options.handles.guiBuildManualModel = handles.guiBuildManualModel;

%Save temprary parameters to this point for if clear button is pressed
opening_P = Parameters;
setappdata(0,'opening_P',opening_P);

setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Update handles structure
guidata(hObject, handles);

function guiBuildManualModel_CloseRequestFcn(hObject, eventdata, handles)
try
    Options = getappdata(0,'Options');
    Options.handles = rmfield(Options.handles,'guiBuildManualModel');
    setappdata(0,'Options',Options);
catch
end

delete(hObject);

function varargout = SteelGirderManual_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

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

function textOutToOutWidth_Callback(hObject, eventdata, handles)

function textOutToOutWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function pushbtnParameters_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0, 'Options');

% Clear outputs with new run
outputs = get(handles.tableOutputs, 'Data');
new_outputs = cell(size(outputs,1),size(outputs,2));
new_outputs(:,1) = outputs(:,1);
set(handles.tableOutputs, 'Data', new_outputs);


if ~isfield(Parameters, 'NumGirder')
    Parameters.NumGirder = str2double(get(handles.editNumGirder, 'string'));
    Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
    NumGirder = Parameters.NumGirder;
    GirderSpacing = Parameters.GirderSpacing;
else
    NumGirder = str2double(get(handles.editNumGirder, 'string'));
    GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
end

inputs = get(handles.tableInputs, 'Data');

% Error Checking
for ii = 1:length(inputs)
    if isempty(inputs{ii,2}) || isempty(inputs{ii,3})
        msgbox('Please Assign Interior and Exterior Beam Section or Cancel', 'Missing Beam Section','error');
        return
    end
end

% TEMPORARY: Save Parameters.Beam as Int and Ext
% Beam = Parameters.Beam;
% Parameters.Beam.Int = Beam;
% Parameters.Beam.Ext = Beam;

% Interior Girder
Parameters.Beam.Int.Des = 'Int';
Parameters.Beam.Int.d = inputs{1,2};
Parameters.Beam.Int.bf = inputs{2,2};
Parameters.Beam.Int.tf = inputs{3,2};
Parameters.Beam.Int.tw = inputs{4,2};

if Parameters.Spans > 1
    Parameters.Beam.Int.CoverPlate.Length = inputs{5,2};
    Parameters.Beam.Int.CoverPlate.t = inputs{6,2};
    Parameters.Beam.Int.CoverPlate.Ratio = Parameters.Beam.Int.CoverPlate.Length/max(Parameters.Length);
    Parameters.Beam.Int.CoverPlate.d = Parameters.Beam.Int.d + 2*Parameters.Beam.Int.CoverPlate.t;
    Parameters.Beam.Int.CoverPlate.bf = Parameters.Beam.Int.bf;
    Parameters.Beam.Int.CoverPlate.tf = Parameters.Beam.Int.tf + Parameters.Beam.Int.CoverPlate.t;
    Parameters.Beam.Int.CoverPlate.tw = Parameters.Beam.Int.tw;
end

% Exterior Girder
Parameters.Beam.Ext.Des = 'Ext';
Parameters.Beam.Ext.d = inputs{1,3};
Parameters.Beam.Ext.bf = inputs{2,3};
Parameters.Beam.Ext.tf = inputs{3,3};
Parameters.Beam.Ext.tw = inputs{4,3};

if Parameters.Spans > 1
    Parameters.Beam.Ext.CoverPlate.Length = inputs{5,3};
    Parameters.Beam.Ext.CoverPlate.t = inputs{6,3};
    Parameters.Beam.Ext.CoverPlate.Ratio = Parameters.Beam.Int.CoverPlate.Length/max(Parameters.Length);
    Parameters.Beam.Ext.CoverPlate.d = Parameters.Beam.Ext.d + 2*Parameters.Beam.Ext.CoverPlate.t;
    Parameters.Beam.Ext.CoverPlate.bf = Parameters.Beam.Ext.bf;
    Parameters.Beam.Ext.CoverPlate.tf = Parameters.Beam.Ext.tf + Parameters.Beam.Ext.CoverPlate.t;
    Parameters.Beam.Ext.CoverPlate.tw = Parameters.Beam.Ext.tw;
end

% Cover PLate
if Parameters.Spans > 1
    Parameters.Beam.CoverPlate = Parameters.Beam.Int.CoverPlate;
end

% Code
if get(handles.radiobtnDesign_LRFD, 'value') == 1
    Parameters.Design.Code = 'LRFD';
    Parameters.Design.DesignLoad = 'A';
else
    Parameters.Design.Code = 'ASD';
end


% Calculate properties, forces, and capacity for parameters
h = waitbar(0,'Please Wait While Model Properties Are Calculated...');

waitbar(.25,h);
Parameters = GetStructureConfig([],Parameters,[],Options);
Parameters = AASHTODesign(Parameters);

if ~isfield(Parameters.Design, 'Load')
    waitbar(.7,h);
    Parameters = GetMemberActions(Parameters);
elseif Parameters.NumGirder ~= NumGirder || Parameters.GirderSpacing ~= GirderSpacing
    Parameters.NumGirder = NumGirder;
    Parameters.GirderSpacing = GirderSpacing;
    waitbar(.7,h);
    Parameters = GetMemberActions(Parameters);
end 

waitbar(.8,h);
Parameters.ModelType = 'Manual'; % Temprarily assign ModelType for GetSectionProperties
[Parameters, Parameters.Beam.Int] = GetSectionProperties(Parameters.Beam.Int, Parameters);
[Parameters, Parameters.Beam.Ext] = GetSectionProperties(Parameters.Beam.Ext, Parameters);
Parameters = rmfield(Parameters, 'ModelType');

waitbar(.9,h);
% Shapes
old = cd('../');
filepath = [pwd '\Tables\CShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\LShapes_Current.mat'];
load(filepath);
cd(old);

Parameters.Beam.d = max(Parameters.Beam.Int.d, Parameters.Beam.Ext.d); % Temporarily Assign d for GetDiaphragmRequirement
Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
Parameters.Beam = rmfield(Parameters.Beam, 'd');

[Parameters, Parameters.Demands.Int] = GetSectionForces(Parameters.Beam.Int, Parameters);
[Parameters, Parameters.Demands.Ext] = GetSectionForces(Parameters.Beam.Ext, Parameters);

waitbar(1,h)
Parameters.Beam.Int = GetLRFDResistance(Parameters.Beam.Int, Parameters.Demands.Int, Parameters);
Parameters.Beam.Ext = GetLRFDResistance(Parameters.Beam.Ext, Parameters.Demands.Ext, Parameters);
close(h);

outputs = get(handles.tableOutputs, 'Data');

if Parameters.Spans == 1
    if strcmp(Parameters.Dia.Assign, 'Auto')
        outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Dia.SectionName};
        outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Dia.SectionName};
    else
        outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Dia.SectionName};
        outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Dia.SectionName};
    end        
else
     if strcmp(Parameters.Dia.Assign, 'Auto')
        if Parameters.Beam.CoverPlate.t > 0
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                Parameters.Beam.Int.CoverPlate.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.CoverPlate.A; Parameters.Dia.SectionName};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                Parameters.Beam.Ext.CoverPlate.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.CoverPlate.A; Parameters.Dia.SectionName};
        else
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.A; Parameters.Dia.SectionName};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.A; Parameters.Dia.SectionName};
        end
    else
        if Parameters.Beam.CoverPlate.t > 0
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                Parameters.Beam.Int.CoverPlate.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.CoverPlate.A};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                Parameters.Beam.Ext.CoverPlate.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.CoverPlate.A};
        else
            outputs(:,2) = {Parameters.Beam.Int.Mn_pos; Parameters.Beam.Int.Fn_neg;Parameters.Beam.Int.I.Ix;...
                Parameters.Beam.Int.I.Ix; Parameters.Beam.Int.A; Parameters.Beam.Int.A};
            outputs(:,3) = {Parameters.Beam.Ext.Mn_pos; Parameters.Beam.Ext.Fn_neg;Parameters.Beam.Ext.I.Ix;...
                Parameters.Beam.Ext.I.Ix; Parameters.Beam.Ext.A; Parameters.Beam.Ext.A};
        end
    end
end

set(handles.tableOutputs, 'Data', outputs);
setappdata(0, 'Parameters', Parameters);

UpdateDiaTables(Parameters, []);

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

if get(handles.radiobtnDesign_LRFD, 'Value') == 1
   Parameters.Design.Code = 'LRFD';
   Parameters.Design.DesignLoad = 'A'; 
elseif get(handles.radiobtnDesign_ASD, 'value') == 1
   Parameters.Design.Code = 'ASD';
   Parameters.Design.DesignLoad = '6';
end
 
% Error checking
if ~isfield(Parameters.Beam, 'Int')
    msgbox('Please calculate parameters before assigning.', 'Missing Parameters', 'error')
    return
end

% newpara = get(handles.tableInputs, 'Data');
% if Parameters.Spans == 1
%     oldpara = cell(4,2);
%     oldpara(:,2) = {Parameters.Beam.Int.d; Parameters.Beam.Int.bf; Parameters.Beam.Int.tf; Parameters.Beam.Int.tw};
%     oldpara(:,3) = {Parameters.Beam.Ext.d; Parameters.Beam.Ext.bf; Parameters.Beam.Ext.tf; Parameters.Beam.Ext.tw};
% else
%     oldpara = cell(6,3);
%     oldpara(:,2) = {Parameters.Beam.Int.d; Parameters.Beam.Int.bf; Parameters.Beam.Int.tf; Parameters.Beam.Int.tw;...
%         Parameters.Beam.Int.CoverPlate.Length; Parameters.Beam.Int.CoverPlate.t};
%     oldpara(:,3) = {Parameters.Beam.Ext.d; Parameters.Beam.Ext.bf; Parameters.Beam.Ext.tf; Parameters.Beam.Ext.tw;...
%         Parameters.Beam.Ext.CoverPlate.Length; Parameters.Beam.Ext.CoverPlate.t};
% end

% for ii = 1:length(newpara)
%     if all(cell2mat(newpara(ii,2)) == cell2mat(oldpara(ii,2)))
%         msgbox('Some input parameters have been changed. Please recalculate parameters before assigning.', 'Parameters Have Been Changed', 'error')
%         return
%     end
% end


% if ~all(Parameters.Beam.Constraints <= 0)
%     if ~isappdata(0, 'count')
%         count = 1;
%         setappdata(0, 'count', count);
%         msgbox('Current member size does not meet AASHTO LRFD Design Specifications', 'Member Size Error', 'error')    
%         return
%     elseif count == 1;
%     end 
% end

if isnan(Parameters.GirderSpacing) || isnan(Parameters.NumGirder)
    msgbox('Please Assign Number of Girders & Girder Spacing or Cancel', 'Missing Beam Information','error');
    return
end

% if isfield(Parameters.Beam, 'CoverPlate')
%     if Parameters.Beam.CoverPlate.t > 2*Parameters.Beam.tf
%         msgbox('Cover plate is larger than twice the flange thickness', 'Cover Plate Design Error', 'error')
%     end
% end

% Save temprary parameters up to this point
P_Temp3 = Parameters;
setappdata(0, 'P_Temp3', P_Temp3);
if isappdata(0, 'opening_P')
   rmappdata(0,'opening_P'); 
end


% TEMPORARY: Save Beam.Int as Beam (until software is capable of building a
% model with different interior and exterior cross-sections)
% Int = Parameters.Beam.Int;
% Ext = Parameters.Beam.Ext;
% Parameters.Beam = Parameters.Beam.Int;
% Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
% Parameters.Beam.Int = Int;
% Parameters.Beam.Ext = Ext;

setappdata(0,'Parameters',Parameters);
set(handles.guiBuildManualModel, 'Visible', 'off');

UpdateDiaTables(Parameters, []);

function pushbtnClear_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'opening_P');

% Clear outputs with new run
inputs = get(handles.tableInputs, 'Data');
new_inputs = cell(size(inputs,1),size(inputs,2));
new_inputs(:,1) = inputs(:,1);
outputs = get(handles.tableOutputs, 'Data');
new_outputs = cell(size(outputs,1),size(outputs,2));
new_outputs(:,1) = outputs(:,1);

if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end

set(handles.tableInputs, 'Data', new_inputs);
set(handles.tableOutputs, 'Data', new_outputs);
set([handles.editNumGirder, handles.editGirderSpacing, handles.textTotalWidth, handles.textOverhang], 'string', '');
setappdata(0, 'Parameters', Parameters);

function pushbtnCancel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_Temp2');
setappdata(0, 'Parameters', Parameters);
if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end
guiBuildManualModel_CloseRequestFcn(handles.guiBuildManualModel, eventdata, handles)

function popupDesignTruck_Callback(hObject, eventdata, handles)

function popupDesignTruck_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

function editNumGirder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editGirderSpacing_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.editNumGirder, 'String')) 
    set(handles.textTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
    set(handles.textOverhang, 'string', (str2double(get(handles.textOutToOutWidth, 'string'))...
        -str2double(get(handles.textTotalWidth, 'string')))/2);
end

function editGirderSpacing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textTotalWidth_Callback(hObject, eventdata, handles)

function textTotalWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textOverhang_Callback(hObject, eventdata, handles)

function textOverhang_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function axisBeamPicture_CreateFcn(hObject, eventdata, handles)

function checkboxIntExt_Callback(hObject, eventdata, handles)
Parameters= getappdata(0, 'Parameters');
inputs = get(handles.tableInputs, 'Data');
if get(hObject, 'value') == 1
    inputs(:,3) = inputs(:,2);
    set(handles.tableInputs, 'Data', inputs)
else
    if Parameters.Spans == 1
        inputs(:,3) = {'';'';'';''};
        set(handles.tableInputs, 'Data', inputs)
    else
        inputs(:,3) = {'';'';'';'';'';''};
        set(handles.tableInputs, 'Data', inputs)
    end
end

function tableInputs_CreateFcn(hObject, eventdata, handles)

function tableOutputs_CreateFcn(hObject, eventdata, handles)

% --- Executes when selected cell(s) is changed in tableInputs.
function tableInputs_CellSelectionCallback(hObject, eventdata, handles)
if get(handles.checkboxIntExt, 'Value') == 1
    inputs = get(hObject, 'Data');
    inputs(:,3) = inputs(:,2);
    set(hObject, 'Data', inputs);
end
    
