function varargout = SteelGirder_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SteelGirder_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SteelGirder_gui_OutputFcn, ...
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
end

function SteelGirder_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% DO NOT EDIT ABOVE THIS LINE--------------------------------------

% Get app data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0,'Options');

% Set guis handles
Options.handles.guiBuildRAMPSModel = handles;

% Show Beam Picture
axes(handles.axisBeamPicture);
old = cd('../');
imshow([pwd '\Img\BeamSection.jpg']);
cd(old);

% --------------------- Default Fields and Checkboxes ---------------------

% Composite Action
Parameters.Deck.CompositeDesign = 1;

% % Span to Depth
% set(handles.editMaxSpantoDepth, 'String', 20);

% % Total width
% set(handles.textOutToOutWidth, 'String', Parameters.Width);

% % Cover plate length
% set(handles.editCoverPlateDesignLength, 'String', Options.Default.CoverPlateLength);

% % Set girder spacing to inactive if NBI data is applies
% if strcmp(Parameters.Geo,'NBI')
%     set(handles.editGirderSpacing, 'enable', 'off');
% end

% % Set Design Code and Design Truck
% if isfield(Parameters, 'NBI')
%     if ~isempty(Parameters.NBI)
%         if strcmp(Parameters.NBI.DesignCode, 'ASD')
%             % Design Codes
%             set(handles.radiobtnDesign_ASD, 'Value', 1, 'enable', 'inactive');
% %             set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
%             set(handles.radiobtnDesign_LRFD, 'Value', 0, 'enable', 'on');
%             
%             % Design Trucks
%             tempcd = pwd;
%             cd('../');
%             load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
%             cd(tempcd);
%             
%             set(handles.popupDesignTruck, 'String', DesignTruckList);
%             
%             if str2double(Parameters.NBI.DesignLoad) >= 1 && str2double(Parameters.NBI.DesignLoad) <= 6
%                 set(handles.popupDesignTruck, 'Value', str2double(Parameters.NBI.DesignLoad));
%             else
%                 set(handles.popupDesignTruck, 'Value', 6);
%             end
%             
%             Parameters.Design.DesignLoad = '6';
%             Parameters.Design.Code = 'ASD';
%         else
%             % Design Codes
%             set(handles.radiobtnDesign_ASD, 'Value', 0, 'enable', 'on');
% %             set(handles.radiobtnDesign_LFD, 'Value', 0, 'enable', 'off');
%             set(handles.radiobtnDesign_LRFD, 'Value', 1, 'enable', 'inactive');
%             
%             set(handles.popupDesignTruck, 'String', {'HL-93'});
%             set(handles.popupDesignTruck, 'Value', 1);
%         end
%         
%         Parameters.Design.DesignLoad = 'A';
%     
%          % Truck Loads
%         Parameters.Design = GetTruckLoads(Parameters.Design);
%     end
% end

% Default design code
% set(handles.radiobtnDesign_LRFD, 'value', 1);
% set(handles.popupDesignTruck, 'String', {'HL-93'});
% set(handles.popupDesignTruck, 'Value', 1);
% Parameters.Design.Code = 'LRFD';
% Parameters.Design.DesignLoad = 'A';

% % Default Build Method
% set(handles.Radiobtn_RAMPS,'value',1);
% 
% % Default Section method
% set(handles.Radiobtn_Seperate,'value',1);

% UPDATE GUI ------------------------------------------------------

if ~isempty(Parameters.Beam.Type)
    State = 'Update';
else
    State = 'Init';
end
UpdateSteelGirderGUI(Parameters, Options, State);

% if Parameters.Spans == 1
%     % First column "Girder Properties" headers for single span model
%     data = cell(10,2);
%     data(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';'Web Thickness [in]';...
%         'Positive Capacity [lb-in]'; 'Moment of Inertia, Ix [in^4]'; 'Section Area [in^2]';'Dia Section';...
%         'Controlling St1 Rating'; 'Controlling Sv2 Rating'};
%     % Fill second  and third columns if data is already available. (For
%     % when window is closed and then re-opened)
%     if isappdata(0, 'P_Temp3')
%         Section = {'Int';'Ext'};
%         for jj = 1:2
%             data(:,jj+1) = {Parameters.Beam.(Section{jj}).d; Parameters.Beam.(Section{jj}).bf; Parameters.Beam.(Section{jj}).tf; Parameters.Beam.(Section{jj}).tw;...
%                 Parameters.Beam.(Section{jj}).Mn_pos, Parameters.Beam.(Section{jj}).I.Ix, Parameters.Beam.(Section{jj}).A; Parameters.Dia.SectionName...
%                 [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Strength1_inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Strength1_op))];...
%                 [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Service2_inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Service2_op))]};          
%         end
%     end    
% else
%     % First column "Girder Properties" headers for two span model
%     data = cell(15,2);
%     data(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';...
%     'Web Thickness [in]'; 'Cover Plate Length [in]'; 'Cover Plate Thickness [in]'; ...
%     'Positive Capacity [lb-in]'; 'Negative Capacity [psi]'; 'Positive Ix [in^4]';...
%     'Negative Ix [in^4]';'Positive Section Area [in^2]'; 'Negative Section Area [in^2]';...
%     'Dia Section';'Controlling St1 Rating';'Controlling Sv2 Rating'};
%     % Fill second  and third columns if data is already available. (For
%     % when window is closed and then re-opened)
%     if isappdata(0, 'P_Temp3')
%         set(handles.editNumGirder,'string',num2str(Parameters.NumGirder));
%         set(handles.editGirderSpacing,'string',num2str(Parameters.GirderSpacing));
%         set(handles.textTotalWidth,'string',num2str(Parameters.TotalWidth));
%         set(handles.textOverhang,'string',num2str(Parameters.Overhang));
%         Section = {'Int';'Ext'};
%         for jj = 1:2
%             data(:,jj+1) = {Parameters.Beam.(Section{jj}).d; Parameters.Beam.(Section{jj}).bf; Parameters.Beam.(Section{jj}).tf; Parameters.Beam.(Section{jj}).tw;...
%                 Parameters.Beam.(Section{jj}).CoverPlate.Length; Parameters.Beam.(Section{jj}).CoverPlate.t;...
%                 Parameters.Beam.(Section{jj}).Mn_pos; Parameters.Beam.(Section{jj}).Fn_neg; Parameters.Beam.(Section{jj}).I.Ix;Parameters.Beam.(Section{jj}).CoverPlate.I.Ix;...
%                 Parameters.Beam.(Section{jj}).A; Parameters.Beam.(Section{jj}).CoverPlate.A; Parameters.Dia.SectionName;...
%                 [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Strength1_inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Strength1_op))];...
%                 [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Service2_inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Service2_op))]};         
%         end
%     end
% end
%  
% set(handles.GirderTable, 'Data', data);


% % Cover plate
% if Parameters.Spans == 1
%     set(handles.editCoverPlateDesignLength, 'Value', 0, 'enable', 'off');
%     set(handles.textCPratio,'enable','off');
%     set(handles.checkboxCoverPlate, 'enable', 'off');
%     Parameters.Beam.CoverPlate.Ratio = 0;
% end

% Set app data
% Options.handles.guiBuildRAMPSModel = handles.guiBuildRAMPSModel;
setappdata(0,'Options', Options);
setappdata(0,'Parameters', Parameters);

% Save temporary Parameters
opening_P = Parameters;
setappdata(0, 'opening_P', opening_P);

% Update handles structure
guidata(hObject, handles);
end

function guiBuildRAMPSModel_CloseRequestFcn(hObject, eventdata, handles)
try
    Options = getappdata(0,'Options');
    Options.handles = rmfield(Options.handles,'guiBuildRAMPSModel');
    setappdata(0,'Options',Options);
catch
end

delete(hObject);
end

function varargout = SteelGirder_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
end

% Creation Functions ------------------------------------------------------
function NotBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function textOutToOutWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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
end

function popupDesignTruck_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editMaxSpantoDepth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editNumGirder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editGirderSpacing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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
end

function textOverhang_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function axisBeamPicture_CreateFcn(hObject, eventdata, handles)
end

% Button/Checkbox Callbacks -----------------------------------------------

function checkboxCoverPlate_Callback(hObject, eventdata, handles)
% Enable/Disable CP Ratio input box
if get(hObject, 'value') == 1
    set(handles.editCoverPlateDesignLength, 'enable', 'on');
else
    set(handles.editCoverPlateDesignLength, 'enable', 'inactive');
    set(handles.editCoverPlateDesignLength, 'string', '0');
end
end

function Radiobtn_Manual_Callback(hObject, eventdata, handles)
% Set Radiobtn_RAMPS value to 0, enable to on.
set(handles.Radiobtn_RAMPS,'value',0,'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
% Set Columns in GirderTable to editable.
editable = [false true true];
set(handles.GirderTable,'ColumnEditable', editable);
% Set pushbtnRun string to "Calculate Parameters"
set(handles.pushbtnRun,'string','Calculate Parameters');
% Set "Cover Plate" panel objects enable to off
set([handles.checkboxCoverPlate,handles.textCPratio,...
    handles.editCoverPlateDesignLength],'enable','off');
% Set "Span to Depth" enable to off
set(handles.text1,'enable','off');
set(handles.editMaxSpantoDepth,'enable','off');

end

function Radiobtn_RAMPS_Callback(hObject, eventdata, handles)
% Set Radiobtn_Manual value to 0, enable on.
set(handles.Radiobtn_Manual,'value',0 , 'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
% Set Columns in GirderTable to editable.
editable = [false,false,false];
set(handles.GirderTable,'ColumnEditable', editable);
% Set pushbtnRun string to "Size Girder"
set(handles.pushbtnRun,'string','Size Girder');
% Set "Cover Plate" panel objects enable to on
set([handles.checkboxCoverPlate,handles.textCPratio,...
    handles.editCoverPlateDesignLength],'enable','on');
% Set "Span to Depth" enable to on
set(handles.text1,'enable','on');
set(handles.editMaxSpantoDepth,'enable','on');

end

function radiobtnDesign_ASD_Callback(hObject, eventdata, handles)
% Set radiobtnDesign_LRFD value to 0, enable on.
set(handles.radiobtnDesign_LRFD,'value',0 , 'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
% Design Trucks
tempcd = pwd;
cd('../');
load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
cd(tempcd);
set(handles.popupDesignTruck, 'String', DesignTruckList, 'Value', 6);
% call truck list for the default truck
popupDesignTruck_Callback(handles.popupDesignTruck, eventdata, handles);
end

function radiobtnDesign_LRFD_Callback(hObject, eventdata, handles)
% Set radiobtnDesign_ASD value to 0, enable on.
set(handles.radiobtnDesign_ASD,'value',0 , 'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
% Set Default design truck
set(handles.popupDesignTruck, 'String', {'HL-93'});
set(handles.popupDesignTruck, 'Value', 1);
% call truck list for the default truck
popupDesignTruck_Callback(handles.popupDesignTruck, eventdata, handles);
end

function Radiobtn_all_Callback(hObject, eventdata, handles)
% Set Radiobtn_Seperate value to 0, enable to on.
set(handles.Radiobtn_Seperate,'value',0,'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
end

function Radiobtn_Seperate_Callback(hObject, eventdata, handles)
% Set Radiobtn_Seperate value to 0, enable to on.
set(handles.Radiobtn_all,'value',0,'enable','on');
% Set hObject enable to off.
set(hObject,'enable','inactive');
end

function pushbtnRun_Callback(hObject, eventdata, handles)
if get(handles.Radiobtn_Manual,'value') == 1
    CalculateProperties(hObject,eventdata,handles);
    % Set "Assign" push button enable to on
    set(handles.pushbtnAssign,'enable','on');
else
    RunDesign(hObject,eventdata,handles);
    % Set "Assign" push button enable to on
    set(handles.pushbtnAssign,'enable','on');
end
end

function pushbtnAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Assign ModelType
if get(handles.Radiobtn_Manual,'value') == 1
    Parameters.ModelType = 'Manual'; 
else
    Parameters.ModelType = 'RAMPS Design';
end

% Assign design truck and load
if get(handles.radiobtnDesign_LRFD, 'value') == 1
    Parameters.Design.Code = 'LRFD';
    Parameters.Design.DesignLoad = 'A';
else
    Parameters.Design.DesignLoad = '6';
    Parameters.Design.Code = 'ASD';
end

% Error screen if inuts have changed.
if get(handles.Radiobtn_Manual,'value') == 1
    Section = {'Int';'Ext'};
    newdims = get(handles.GirderTable, 'Data');
    if Parameters.Spans == 1
        newdims = cell2mat(newdims(1:4,2:3));    
        for jj = 1:2
            olddims(:,jj) = [Parameters.Beam.(Section{jj}).d;Parameters.Beam.(Section{jj}).bf;Parameters.Beam.(Section{jj}).tf;...
                        Parameters.Beam.(Section{jj}).tw];
        end
    else
        newdims = cell2mat(newdims(1:6,2:3));
        for jj = 1:2
            olddims(:,jj) = [Parameters.Beam.(Section{jj}).d;Parameters.Beam.(Section{jj}).bf;Parameters.Beam.(Section{jj}).tf;...
                    Parameters.Beam.(Section{jj}).tw;Parameters.Beam.(Section{jj}).CoverPlate.Length;Parameters.Beam.(Section{jj}).CoverPlate.t];
        end
    end

    if min(all(newdims == olddims)) < 1
        msgbox('Please calculate parameters before continuing.', 'Inputs have changed.', 'error')    
        return
    end
    
    % Error Screen coverplate too large
    Section = {'Int';'Ext'};

    for jj = 1:2
        if isfield(Parameters.Beam.(Section{jj}), 'CoverPlate')
            if Parameters.Beam.(Section{jj}).CoverPlate.t > 2*Parameters.Beam.(Section{jj}).tf
      
                msgbox('Cover plate is larger than twice the flange thickness', 'Cover Plate Design Error', 'error')
                return
            end
        end
    end

end

% Error screen numGirder & girderSpacing
if isnan(Parameters.GirderSpacing) || isnan(Parameters.NumGirder)
    msgbox('Please Assign Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
end


% Save temprary parameters up to this point
P_Temp3 = Parameters;
setappdata(0, 'P_Temp3', P_Temp3);
% rmappdata(0,'opening_P');

setappdata(0,'Parameters',Parameters);
% set(handles.guiBuildRAMPSModel, 'Visible', 'off');
end

function pushbtnClear_Callback(hObject, eventdata, handles)
% Set "Assign" push button enable to off
set(handles.pushbtnAssign,'enable','off');

Parameters = getappdata(0, 'opening_P');
% Clear Tables
data = get(handles.GirderTable, 'Data');
new_data = cell(size(data,1),size(data,2));
new_data(:,1) = data(:,1);
set(handles.GirderTable, 'Data', new_data);

set(handles.editGirderSpacing, 'string', '');
set(handles.editNumGirder, 'string', '');
set(handles.textTotalWidth, 'string','');
set(handles.textOverhang,'string','');

if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end

set(handles.NotBox, 'value', 1, 'string', {''});
setappdata(0, 'Parameters', Parameters);
end

function pushbtnCancel_Callback(hObject, eventdata, handles)
Parameters = getappdata(0, 'P_Temp2');
setappdata(0, 'Parameters', Parameters);
if isappdata(0, 'P_Temp3')
    rmappdata(0, 'P_Temp3');
end
guiBuildRAMPSModel_CloseRequestFcn(handles.guiBuildRAMPSModel, eventdata, handles)
end

% Input Callbacks ---------------------------------------------------------

function editCoverPlateDesignLength_Callback(hObject, eventdata, handles)
end

function popupDesignTruck_Callback(hObject, eventdata, handles)
end

function editMaxSpantoDepth_Callback(hObject, eventdata, handles)
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
end

function editGirderSpacing_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.editNumGirder, 'String')) 
    set(handles.textTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
    set(handles.textOverhang, 'string', (str2double(get(handles.textOutToOutWidth, 'string'))...
        -str2double(get(handles.textTotalWidth, 'string')))/2);
end
end

function GirderTable_CellSelectionCallback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
% If "all same section" make edited interior values equal exterior values.
if get(handles.Radiobtn_all,'value') == 1
    if Parameters.Spans == 1
        data = get(hObject, 'Data');
        data(1:4,3) = data(1:4,2);
    else
        data = get(hObject, 'Data');
        data(1:6,3) = data(1:6,2);
    end
    set(hObject, 'Data', data);
end
end

% Output Callbacks --------------------------------------------------------

function NotBox_Callback(hObject, eventdata, handles)
end

function textOutToOutWidth_Callback(hObject, eventdata, handles)
end

function textTotalWidth_Callback(hObject, eventdata, handles)
end

function textOverhang_Callback(hObject, eventdata, handles)
end

% Button Functions --------------------------------------------------------
function CalculateProperties(hObject,eventdata,handles)
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0, 'Options');

if get(handles.Radiobtn_Seperate,'value') == 1
    % Set Section Design
    Section = {'Int';'Ext'};
    beamSection = Section;
    Parameters.Beam.Des = 'Separate Section';
else
    % Set Section Design
    Section = {'All'};
    beamSection = {'Int';'Ext'};
    Parameters.Beam.Des = 'Same Section';
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

% Check for missing values
data = get(handles.GirderTable, 'Data');
if Parameters.Spans == 1
    for ii = 1:4
        if isempty(data{ii,2}) || isempty(data{ii,3})
            msgbox('Please Assign Interior and Exterior Beam Section or Cancel', 'Missing Beam Section','error');
            return
        end
    end
else
    for ii = 1:6
        if isempty(data{ii,2}) || isempty(data{ii,3})
            msgbox('Please Assign Interior and Exterior Beam Section or Cancel', 'Missing Beam Section','error');
            return
        end
    end
end

% Clear GirderTable data with new run (clears calculated values and
% leaves input dimension values)
data = get(handles.GirderTable, 'Data');
new_data = cell(size(data,1),size(data,2));
if Parameters.Spans == 1
   new_data(:,1) = data(:,1); 
   new_data(1:4,2) = data(1:4,2);
   new_data(1:4,3) = data(1:4,3);
else
   new_data(:,1) = data(:,1); 
   new_data(1:6,2) = data(1:6,2);
   new_data(1:6,3) = data(1:6,3);
end
set(handles.GirderTable, 'Data', new_data);

% Error Checking for missing NumGirder or GirderSpacing
if isnan(str2double(get(handles.editNumGirder, 'string'))) || isnan(str2double(get(handles.editGirderSpacing, 'string')))
    msgbox('Please Assign Girder Number and Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
else
   Parameters.NumGirder = str2double(get(handles.editNumGirder, 'string'));
   Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
end


% Populate Parameters from GUI inputs for interior and exterior section
Section = {'Int';'Ext'};
Parameters.Beam.Type = 'Plate';
for jj = 1:2
    Parameters.Beam.(Section{jj}).Des = Section{jj};
        if ischar(data{1,jj+1})
            Parameters.Beam.(Section{jj}).d = str2double(data{1,jj+1});
            Parameters.Beam.(Section{jj}).bf = str2double(data{2,jj+1});
            Parameters.Beam.(Section{jj}).tf = str2double(data{3,jj+1});
            Parameters.Beam.(Section{jj}).tw = str2double(data{4,jj+1});
        else
            Parameters.Beam.(Section{jj}).d = data{1,jj+1};
            Parameters.Beam.(Section{jj}).bf = data{2,jj+1};
            Parameters.Beam.(Section{jj}).tf = data{3,jj+1};
            Parameters.Beam.(Section{jj}).tw = data{4,jj+1};
        end
    Parameters.Beam.(Section{jj}).Section = [Parameters.Beam.(Section{jj}).bf, Parameters.Beam.(Section{jj}).bf, ...
        Parameters.Beam.(Section{jj}).d, Parameters.Beam.(Section{jj}).tf, Parameters.Beam.(Section{jj}).tf, Parameters.Beam.(Section{jj}).tw];
    if Parameters.Spans > 1
        if ischar(data{5,jj+1})
            Parameters.Beam.(Section{jj}).CoverPlate.Length = str2double(data{5,jj+1});
            Parameters.Beam.(Section{jj}).CoverPlate.t = str2double(data{6,jj+1});
        else
            Parameters.Beam.(Section{jj}).CoverPlate.Length = data{5,jj+1};
            Parameters.Beam.(Section{jj}).CoverPlate.t = data{6,jj+1};
        end        
        Parameters.Beam.(Section{jj}).CoverPlate.Ratio = Parameters.Beam.(Section{jj}).CoverPlate.Length/max(Parameters.Length);
        Parameters.Beam.(Section{jj}).CoverPlate.d = Parameters.Beam.(Section{jj}).d + 2*Parameters.Beam.(Section{jj}).CoverPlate.t;
        Parameters.Beam.(Section{jj}).CoverPlate.bf = Parameters.Beam.(Section{jj}).bf;
        Parameters.Beam.(Section{jj}).CoverPlate.tf = Parameters.Beam.(Section{jj}).tf +...
            Parameters.Beam.(Section{jj}).CoverPlate.t;
        Parameters.Beam.(Section{jj}).CoverPlate.tw = Parameters.Beam.(Section{jj}).tw;
        Parameters.Beam.(Section{jj}).CoverPlate.Section = [Parameters.Beam.(Section{jj}).CoverPlate.bf,...
            Parameters.Beam.(Section{jj}).CoverPlate.bf, Parameters.Beam.(Section{jj}).CoverPlate.d,...
            Parameters.Beam.(Section{jj}).CoverPlate.tf, Parameters.Beam.(Section{jj}).CoverPlate.tf, Parameters.Beam.(Section{jj}).CoverPlate.tw];
    else
        Parameters.Beam.(Section{jj}).CoverPlate.Length = 0;
        Parameters.Beam.(Section{jj}).CoverPlate.t = 0;
        Parameters.Beam.(Section{jj}).CoverPlate.Ratio = 0;
    end
end

% Code
if get(handles.radiobtnDesign_LRFD, 'value') == 1
    Parameters.Design.Code = 'LRFD';
    Code = 'LRFD';
    Parameters.Design.DesignLoad = 'A';
else
    Parameters.Design.Code = 'ASD';
end

% Begin: Calculate properties, forces, and capacity for interior and
% exterior
h = waitbar(0,'Please Wait While Model Properties Are Calculated...');
waitbar(.25,h);
Parameters = GetStructureConfig([],Parameters,[],Options);
Parameters = AASHTODesign(Parameters, Options);

% Only run SLG FE Approximation if it has not been run already or if
% GirderSpacing and NumGirder are different.
if ~isfield(Parameters.Design,'SLG') 
    waitbar(.5,h, 'Running SLG Approximation...');
    [Parameters, Parameters.Design.SLG.Int] = GetFEApproximation(Parameters, []);
    Parameters.Design.SLG.Ext = Parameters.Design.SLG.Int;
    setappdata(0,'Parameters',Parameters);
end 

waitbar(.7,h, 'Calculating Section Properties...');

% Run GetSectionProperties() for Interior and Exterior
for jj= 1:2
    Parameters.Beam.(Section{jj}) = GetSectionProperties(Parameters.Beam.(Section{jj}),Parameters,Section{jj});
end

waitbar(.8,h, 'Retreiving Diaphragm Requirements...');

% Load Shapes
old = cd('../');
filepath = [pwd '\Tables\CShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\LShapes_Current.mat'];
load(filepath);
cd(old);

% Run GetDiaphragmRequirement for Exterior 
Parameters = GetDiaSection(Parameters, CShapes, LShapes, Parameters.Beam.Ext);
waitbar(1,h,'Finalizing section parameter calculations....')

% Run LRFDDistFact(), GetSectionForces(), GetLRFDResistance(), and CompactCheckLRFD() for interior and exterior
for jj = 1:2
    % Distribution Factors
    [Parameters.Design.DF.(['DF' (Section{jj})]), Parameters.Design.DF.(['DFV' (Section{jj})])] = LRFDDistFact(Parameters, Parameters.Beam.(Section{jj}));
    % Demands
    Parameters.Demands.(Section{jj}).SL = GetSectionForces(Parameters.Beam.(Section{jj}), Parameters, Parameters.Design.Code, Section{jj},1);
    % Capacity
    Parameters.Beam.(Section{jj}) = GetLRFDResistance(Parameters.Beam.(Section{jj}), Parameters.Demands.(Section{jj}).SL, Parameters, Section{jj}, []);
    % Compactness
    Parameters.Beam.(Section{jj}) = CompactCheckLRFD(Parameters.Beam.(Section{jj}),Parameters);
end
close(h);
   
cell_listbox = {get(handles.NotBox, 'string')};
length_cell_listbox = length(cell_listbox);    
msg{1} = 'Property Calculations Complete...';
msg{2} = 'Design Summary:';
msg{3} = Parameters.Beam.Type;
if strcmp(Parameters.Design.Code, 'LRFD')
    for jj = 1:length(beamSection)
        % Compactness
        Parameters.Beam.(beamSection{jj}) = CompactCheckLRFD(Parameters.Beam.(beamSection{jj}),Parameters);
        if Parameters.Beam.(beamSection{jj}).SectionComp == 1
            msg{length(msg)+1} = [beamSection{jj} ' Section Compact in Positive Region'];
        else
            msg{length(msg)+1} = [beamSection{jj} ' Section Non-Compact in Positive Region'];
        end
        if Parameters.Spans > 1
            if Parameters.Beam.(beamSection{jj}).FlangeComp == -1
                msg{length(msg)+1} = [beamSection{jj} ' Flange Slender in Negative Region'];
            elseif Parameters.Beam.(beamSection{jj}).FlangeComp == 0
                msg{length(msg)+1} = [beamSection{jj} ' Flange Compact in Negative Region'];
            elseif Parameters.Beam.(beamSection{jj}).FlangeComp == 1
                msg{length(msg)+1} = [beamSection{jj} ' Flange Non-Compact in Negative Region'];
            end
            if Parameters.Beam.(beamSection{jj}).WebComp == -1
                msg{length(msg)+1} = [beamSection{jj} ' Web Slender in Negative Region'];
            elseif Parameters.Beam.(beamSection{jj}).WebComp == 0
                msg{length(msg)+1} = [beamSection{jj} ' Web Compact in Negative Region'];
            elseif Parameters.Beam.(beamSection{jj}).WebComp == 1
                msg{length(msg)+1} = [beamSection{jj} ' Web Non-Compact in Negative Region'];
            end
        end
    end
end   
    
for ii = 1:length(msg)
    cell_listbox{length_cell_listbox +ii} = msg{ii};
    set(handles.NotBox, 'string', cell_listbox);
    set(handles.NotBox, 'Value', length_cell_listbox +ii);
end
  
% Get SingleLine Rating    
Parameters.Rating.Code = Parameters.Design.Code;
Parameters.Rating.(Code).DesignLoad = Parameters.Design.DesignLoad;
Parameters.Rating.(Code).useCB = 0;

% Get Trucks
Parameters.Rating.(Code) = GetTruckLoads(Parameters.Rating.(Code));

% AASHTO Load Rating
[Parameters, Parameters.Rating.(Code)] = AASHTOLoadRating(Parameters.Rating.(Code), Parameters);

Parameters.Rating.(Code).Load.A = Parameters.Rating.(Code).Load.A*Parameters.Rating.(Code).IMF;
Parameters.Rating.(Code).Load.TD = Parameters.Rating.(Code).Load.TD*Parameters.Rating.(Code).IMF;
% Get Rating Factor
for jj = 1:2
    Parameters.Rating.(Code).SL.(Section{jj}) = GetRatingFactor(Parameters.Beam.(Section{jj}),Parameters.Demands.(Section{jj}).SL,Parameters,Section{jj});
end

% Populate GirderTable 
    data = get(handles.GirderTable, 'Data');
    for jj = 1:length(beamSection)
        if Parameters.Spans == 1
            data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;Parameters.Beam.(beamSection{jj}).tw;...
                Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).I.Ix; Parameters.Beam.(beamSection{jj}).A;...
                Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.RFOp_pos))];...
                [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.RFOp_pos))]};        
        else
            if Parameters.Beam.(beamSection{jj}).CoverPlate.Length > 0
                data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;...
                    Parameters.Beam.(beamSection{jj}).tw;Parameters.Beam.(beamSection{jj}).CoverPlate.Length;Parameters.Beam.(beamSection{jj}).CoverPlate.t;...
                    Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).Fn_neg;Parameters.Beam.(beamSection{jj}).I.Ix;...
                    Parameters.Beam.(beamSection{jj}).CoverPlate.I.Ix; Parameters.Beam.(beamSection{jj}).A; Parameters.Beam.(beamSection{jj}).CoverPlate.A;...
                    Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Op))];...
                    [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Op))]};
            else
                data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;...
                    Parameters.Beam.(beamSection{jj}).tw;Parameters.Beam.(beamSection{jj}).CoverPlate.Length;Parameters.Beam.(beamSection{jj}).CoverPlate.t;...
                    Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).Fn_neg;Parameters.Beam.(beamSection{jj}).I.Ix;...
                    Parameters.Beam.(beamSection{jj}).I.Ix; Parameters.Beam.(beamSection{jj}).A; Parameters.Beam.(beamSection{jj}).A;...
                    Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Op))];...
                    [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Op))]};
            end
        end
    end
      
set(handles.GirderTable, 'Data', data);
setappdata(0, 'Parameters', Parameters);
end

function RunDesign(hObject,eventdata,handles)
% Get app data
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

% Design Code
if get(handles.radiobtnDesign_LRFD, 'value')
    Parameters.Design.Code = 'LRFD';
    Parameters.Design.DesignLoad = 'A';
elseif get(handles.radiobtnDesign_ASD, 'value')
    Parameters.Design.Code = 'ASD';
    Parameters.Design.DesignLoad = '9';
end
    
if get(handles.Radiobtn_Seperate,'value') == 1
    % Set Section Design
    Section = {'Int';'Ext'};
    beamSection = Section;
    Parameters.Beam.Des = 'Separate Section';
else
    % Set Section Design
    Section = {'All'};
    beamSection = {'Int';'Ext'};
    Parameters.Beam.Des = 'Same Section';
end

% Error checking
if isnan(str2double(get(handles.editNumGirder, 'string'))) || isnan(str2double(get(handles.editGirderSpacing, 'string')))
    msgbox('Please Assign Girder Number and Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
else
   Parameters.NumGirder = str2double(get(handles.editNumGirder, 'string'));
   Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'string'));
end

% Get Girder Spacing Field and Compute Num Girder
Parameters.Design.MaxSpantoDepth = str2double(get(handles.editMaxSpantoDepth, 'String'));

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

% Clear previously designed dimensions (if run previously)
data = get(handles.GirderTable, 'Data');
new_data = cell(size(data,1),size(data,2));
new_data(:,1) = data(:,1);
set(handles.GirderTable, 'Data', new_data);

% NBI
if strcmp(Parameters.Geo, 'NBI')
    NBI = getappdata(0,'NBI');
else
    NBI = [];
end

% Cover plate length for interior and exterior
for jj = 1:length(beamSection)
    if Parameters.Spans > 1 && get(handles.checkboxCoverPlate, 'value') == 1
        Parameters.Beam.(beamSection{jj}).CoverPlate.Ratio = str2double(get(handles.editCoverPlateDesignLength, 'String'));
        Parameters.Beam.(beamSection{jj}).CoverPlate.Length = Parameters.Beam.(beamSection{jj}).CoverPlate.Ratio*max(Parameters.Length);
    else
        Parameters.Beam.(beamSection{jj}).CoverPlate.Ratio = 0;
        Parameters.Beam.(beamSection{jj}).CoverPlate.Length = 0;
        Parameters.Beam.(beamSection{jj}).CoverPlate.t = 0;
    end
end


% Run Design
h = waitbar(0,'Please Wait While RAMPS Design is Executed...'); 

waitbar(.1,h, 'Finalizing Structure Configuration');
Parameters = GetStructureConfig(NBI, Parameters, [], Options);
waitbar(.2,h, 'Getting AASHTO Design Parameters');
Parameters = AASHTODesign(Parameters, Options);
waitbar(.5,h, 'Calculating Line Girder Member Actions');

% Only run GetMemberActions if it has not been run already or if
% GirderSpacing and NumGirder are different.
if ~isfield(Parameters.Design,'SLG')
    [Parameters, Parameters.Design.SLG.Int] = GetFEApproximation(Parameters, []);
    Parameters.Design.SLG.Ext = Parameters.Design.SLG.Int;
    setappdata(0,'Parameters',Parameters);
end 

waitbar(.55,h,'Calculation Live Load Deflections');
Parameters = GetAASHTOLLDeflectionRequirement(Parameters);
waitbar(.7,h, 'Finding Girder Section...');
% Load Shapes
oldFolder = pwd;
cd('..\');
filepath = [pwd '\Tables\WShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\CShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\LShapes_Current.mat'];
load(filepath);
cd(oldFolder);
% Run girder sizing
Parameters = GirderSizing(Parameters, Options,Section,CShapes, WShapes, LShapes);


% Set Values to Beam
if ~strcmp(Parameters.Beam.Type, 'None')    
    cell_listbox = {get(handles.NotBox, 'string')};
    length_cell_listbox = length(cell_listbox);    
    msg{1} = 'RAMPS Design Complete...';
    msg{2} = 'Design Summary:';
    msg{3} = Parameters.Beam.Type;
    if strcmp(Parameters.Design.Code, 'LRFD')
        for jj = 1:length(beamSection)
            % Compactness
            Parameters.Beam.(beamSection{jj}) = CompactCheckLRFD(Parameters.Beam.(beamSection{jj}),Parameters);
            if Parameters.Beam.(beamSection{jj}).SectionComp == 1
                msg{length(msg)+1} = [beamSection{jj} ' Section Compact in Positive Region'];
            else
                msg{length(msg)+1} = [beamSection{jj} ' Section Non-Compact in Positive Region'];
            end
            if Parameters.Spans > 1
                if Parameters.Beam.(beamSection{jj}).FlangeComp == -1
                    msg{length(msg)+1} = [beamSection{jj} ' Flange Slender in Negative Region'];
                elseif Parameters.Beam.(beamSection{jj}).FlangeComp == 0
                    msg{length(msg)+1} = [beamSection{jj} ' Flange Compact in Negative Region'];
                elseif Parameters.Beam.(beamSection{jj}).FlangeComp == 1
                    msg{length(msg)+1} = [beamSection{jj} ' Flange Non-Compact in Negative Region'];
                end
                if Parameters.Beam.(beamSection{jj}).WebComp == -1
                    msg{length(msg)+1} = [beamSection{jj} ' Web Slender in Negative Region'];
                elseif Parameters.Beam.(beamSection{jj}).WebComp == 0
                    msg{length(msg)+1} = [beamSection{jj} ' Web Compact in Negative Region'];
                elseif Parameters.Beam.(beamSection{jj}).WebComp == 1
                    msg{length(msg)+1} = [beamSection{jj} ' Web Non-Compact in Negative Region'];
                end
            end
        end
    end   
    for ii = 1:length(msg)
        cell_listbox{length_cell_listbox +ii} = msg{ii};
        set(handles.NotBox, 'string', cell_listbox);
        set(handles.NotBox, 'Value', length_cell_listbox +ii);
    end
  
  % Get SingleLine Rating    
    Parameters.Rating.Code = Parameters.Design.Code;
    Code = Parameters.Rating.Code;
    Parameters.Rating.(Code).DesignLoad = Parameters.Design.DesignLoad;
    Parameters.Rating.(Code).useCB = 0;

    % Get Trucks
    Parameters.Rating.(Code) = GetTruckLoads(Parameters.Rating.(Code));

    % AASHTO Load Rating
    [Parameters,Parameters.Rating.(Code)] = AASHTOLoadRating(Parameters.Rating.(Code),Parameters);

    Parameters.Rating.(Code).Load.A = Parameters.Rating.(Code).Load.A*Parameters.Rating.(Code).IMF;
    Parameters.Rating.(Code).Load.TD = Parameters.Rating.(Code).Load.TD*Parameters.Rating.(Code).IMF;
    % Get Rating Factor
    for jj = 1:2
        Parameters.Rating.(Code).SL.(beamSection{jj}) = GetRatingFactor(Parameters.Beam.(beamSection{jj}),Parameters.Demands.(beamSection{jj}).SL,Parameters,beamSection{jj});
    end
    
    % Populate GirderTable 
    data = get(handles.GirderTable, 'Data');
    for jj = 1:length(beamSection)
        if Parameters.Spans == 1
            data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;Parameters.Beam.(beamSection{jj}).tw;...
                Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).I.Ix; Parameters.Beam.(beamSection{jj}).A;...
                Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.RFOp_pos))];...
                [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.RFOp_pos))]};        
        else
            if Parameters.Beam.(beamSection{jj}).CoverPlate.Length > 0
                data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;...
                    Parameters.Beam.(beamSection{jj}).tw;Parameters.Beam.(beamSection{jj}).CoverPlate.Length;Parameters.Beam.(beamSection{jj}).CoverPlate.t;...
                    Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).Fn_neg;Parameters.Beam.(beamSection{jj}).I.Ix;...
                    Parameters.Beam.(beamSection{jj}).CoverPlate.I.Ix; Parameters.Beam.(beamSection{jj}).A; Parameters.Beam.(beamSection{jj}).CoverPlate.A;...
                    Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Op))];...
                    [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Op))]};
            else
                data(:,jj+1) = {Parameters.Beam.(beamSection{jj}).d;Parameters.Beam.(beamSection{jj}).bf;Parameters.Beam.(beamSection{jj}).tf;...
                    Parameters.Beam.(beamSection{jj}).tw;Parameters.Beam.(beamSection{jj}).CoverPlate.Length;Parameters.Beam.(beamSection{jj}).CoverPlate.t;...
                    Parameters.Beam.(beamSection{jj}).Mn_pos; Parameters.Beam.(beamSection{jj}).Fn_neg;Parameters.Beam.(beamSection{jj}).I.Ix;...
                    Parameters.Beam.(beamSection{jj}).I.Ix; Parameters.Beam.(beamSection{jj}).A; Parameters.Beam.(beamSection{jj}).A;...
                    Parameters.Dia.SectionName;[num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).St1.Op))];...
                    [num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(beamSection{jj}).Sv2.Op))]};
            end
        end
    end
      
    set(handles.GirderTable, 'Data', data);
   
else
   
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

end
