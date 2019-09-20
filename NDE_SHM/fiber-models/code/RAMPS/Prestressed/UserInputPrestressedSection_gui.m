function varargout = UserInputPrestressedSection_gui(varargin)
% USERINPUTPRESTRESSEDSECTION_GUI MATLAB code for UserInputPrestressedSection_gui.fig
%      USERINPUTPRESTRESSEDSECTION_GUI, by itself, creates a new USERINPUTPRESTRESSEDSECTION_GUI or raises the existing
%      singleton*.
%
%      H = USERINPUTPRESTRESSEDSECTION_GUI returns the handle to a new USERINPUTPRESTRESSEDSECTION_GUI or the handle to
%      the existing singleton*.
%
%      USERINPUTPRESTRESSEDSECTION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERINPUTPRESTRESSEDSECTION_GUI.M with the given input arguments.
%
%      USERINPUTPRESTRESSEDSECTION_GUI('Property','Value',...) creates a new USERINPUTPRESTRESSEDSECTION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserInputPrestressedSection_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserInputPrestressedSection_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserInputPrestressedSection_gui

% Last Modified by GUIDE v2.5 25-Aug-2014 12:35:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInputPrestressedSection_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInputPrestressedSection_gui_OutputFcn, ...
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


% --- Executes just before UserInputPrestressedSection_gui is made visible.
function UserInputPrestressedSection_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInputPrestressedSection_gui (see VARARGIN)

% Choose default command line output for UserInputPrestressedSection_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Show Beam Picture
axes(handles.axesPSPicture);
old = cd('../');
imshow([pwd '\Img\PSSection.jpg']);
cd(old);

Parameters = getappdata(0,'Parameters');

if any(Parameters.Length>146*12)
    set(handles.rbBulbTee,'enable','off');
end

% Set List of diameters
Diameters = [.250 .313 .375 .438 .500 .520 .563 .600 .700]';
set(handles.pmDia,'string',Diameters);

% Set List of Rebar Sizes
BarNo = [3 4 5 6 7 8 9 10 11 14 18];
set(handles.popupBarNo,'string',BarNo);

% Assign List of Prestressed Sections
Sections = {'AASHTO Type I'; 'AASHTO Type II'; 'AASHTO Type III';'AASHTO Type IV'; 'AASHTO Type V'; 'AASHTO Type VI'; 'Custom'};
set(handles.listboxSections,'string',Sections);

% Get suggested AASHTO section for span length
Parameters.Beam.Type = 'AASHTO';
[Parameters, exitflag] = GetPSGirder(Parameters);

% Set selection
set(handles.listboxSections,'Value',str2double(Parameters.Beam.Name(end)));

% Inform user if span length is greater than max length of any section
if ~exitflag
    fprintf('Span length may be to large for available sections');
end

% Fill dimension fields
Dims = Parameters.Beam.Section;
set(handles.editD,'string',Dims(1))
set(handles.editbf,'string',Dims(7))
set(handles.edit_bfb,'string',Dims(8))
set(handles.edit_tft,'string',Dims(2))
set(handles.edit_tfb,'string',Dims(6))
set(handles.edit_tw,'string',Dims(9))
set(handles.edit_d1,'string',Dims(3))
set(handles.edit_d2,'string',Dims(4))
set(handles.edit_d3,'string',Dims(5))
set(handles.edit_b1,'string',Dims(14))
set(handles.edit_b2,'string',Dims(15))
set(handles.edit_b3,'string',Dims(16))

% Composite Action
set(handles.checkboxComposite_Deck, 'Value', 1);
Parameters.Deck.CompositeDesign = 1;

% Span to Depth
set(handles.editMaxSpantoDepth, 'String', 20);

% Total width
set(handles.textOutToOutWidth, 'String', Parameters.Width);

setappdata(0,'Parameters', Parameters);


% --- Section listbox selection callback
function listboxSections_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'string'));
Section = contents{get(hObject,'Value')};

DimHandles = [handles.editD handles.editbf handles.edit_bfb handles.edit_tft handles.edit_tfb handles.edit_tw...
    handles.edit_d1 handles.edit_d2 handles.edit_d3 handles.edit_b1 handles.edit_b2 handles.edit_b3];

if ~strcmp(Section,'Custom')
    [~, Dims] = PSSectionChoose(Section);
    set(handles.editD,'string',Dims(1))
    set(handles.editbf,'string',Dims(7))
    set(handles.edit_bfb,'string',Dims(8))
    set(handles.edit_tft,'string',Dims(2))
    set(handles.edit_tfb,'string',Dims(6))
    set(handles.edit_tw,'string',Dims(9))
    set(handles.edit_d1,'string',Dims(3))
    set(handles.edit_d2,'string',Dims(4))
    set(handles.edit_d3,'string',Dims(5))
    set(handles.edit_b1,'string',Dims(14))
    set(handles.edit_b2,'string',Dims(15))
    set(handles.edit_b3,'string',Dims(16))
    set(DimHandles,'style','text');
else
    set(DimHandles,'style','edit')
end

%-----------PUSHBUTTON FUNCTIONS---------------------------------------------
% --- Executes on button press in pushbuttonAssign.
function pushbuttonAssign_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

% Get PS Strand info
Parameters.Beam.PSSteel.NumStrands = str2double(get(handles.textPSNum,'string'));
dias = cellstr(get(handles.pmDia,'String'));
Parameters.Beam.PSSteel.d = str2double(dias{get(handles.pmDia,'Value')});
Parameters.Beam.PSCenter = str2double(get(handles.editPSCG,'string'));
area = [.036 .058 .085 .115 .153 .167 .192 .217 .294]';
Parameters.Beam.PSSteel.Aps = area(get(handles.pmDia,'Value'));

% Get RF Steel Info
Parameters.Beam.RFSteelCheck = get(handles.CompSteelcheck,'Value');
if Parameters.Beam.RFSteelCheck
    Parameters.Beam.RFSteel.NumBars = str2double(get(handles.editNoBars,'string'));
    selection = get(handles.popupBarNo,'value');
    barno = str2num(get(handles.popupBarNo,'string'));
    Parameters.Beam.RFSteel.BarNo = barno(selection);
    Parameters.Beam.RFCenter = str2double(get(handles.editCGCompSteel,'string'));
    Rbar = [.11 .20 .31 .44 .60 .79 1.00 1.27 1.56 2.25 4];
    Parameters.Beam.RFSteel.A = Rbar(selection)*Parameters.Beam.RFSteel.NumBars;
end

% Parameters.Beam.PSForce = str2double(get(handles.textPSNum,'string'));
% Parameters.Beam.PSEcc = str2double(get(handles.editPSCG,'string'));
% if isnan(Parameters.Beam.PSForce)
%     Parameters.Beam.PSForce = 0;
% end

Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'String'));
Parameters.NumGirder = str2double(get(handles.editNumGirder, 'String'));

Parameters = GetStructureConfig([], Parameters, [], Options);

contents = cellstr(get(handles.listboxSections,'string'));
Section = contents{get(handles.listboxSections,'Value')};
if ~strcmp(Section,'Custom')
    [Parameters.Beam,Parameters.Beam.Section] = PSSectionChoose(Section,Parameters.Beam);
else
    [Parameters] = CustomPSSection(Parameters,handles);
end

% Calculate prestressing force in strands

Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';
Parameters.Design = GetTruckLoads(Parameters.Design);
Parameters = AASHTODesign(Parameters);
% Calculate Section Forces
Parameters = PSSectionForces(Parameters);
Parameters = GetPSForce(Parameters);

% Error checking
if isnan(Parameters.Beam.d) || isnan(Parameters.Beam.bft) ||...
        isnan(Parameters.Beam.tw) || isnan(Parameters.Beam.tft(1))||...
        isnan(Parameters.Beam.tfb(1))|| isnan(Parameters.Beam.bfb)
    msgbox('Please Assign Beam Section or Cancel', 'Missing Beam Section','error');
    return
end

if isnan(Parameters.GirderSpacing) || isnan(Parameters.NumGirder)
    msgbox('Please Assign Beam Spacing or Cancel', 'Missing Beam Information','error');
    return
end

setappdata(0,'Parameters',Parameters);

UserInputPSSection_fig_CloseRequestFcn(handles.UserInputPSSection_fig, eventdata, handles)



% --- Executes on button press in pushbuttonClear.
function pushbuttonClear_Callback(hObject, eventdata, handles)
set(handles.editD,'string','')
set(handles.editbf,'string','')
set(handles.edit_bfb,'string','')
set(handles.edit_tft,'string','')
set(handles.edit_tfb,'string','')
set(handles.edit_tw,'string','')
set(handles.edit_d1,'string','')
set(handles.edit_d2,'string','')
set(handles.edit_d3,'string','')
set(handles.edit_b1,'string','')
set(handles.edit_b2,'string','')
set(handles.edit_b3,'string','')


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
UserInputPSSection_fig_CloseRequestFcn(handles.UserInputPSSection_fig, eventdata, handles)


% --------------Creation Fuctions----------------------------------
%
% --- Executes during object creation, after setting all properties.
function listboxSections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function editPSCG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPSCG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editbf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes when user attempts to close UserInputPSSection_fig.
function UserInputPSSection_fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to UserInputPSSection_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

%---------------------VARGOUT---------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = UserInputPrestressedSection_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbDesignPS.
function pbDesignPS_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

clc
set(handles.textPSNum,'string','');
set(handles.editPSCG,'string','');
set(handles.editNoBars,'string','');
set(handles.editCGCompSteel,'string','');

drawnow
% Get section type choice
if get(handles.rbAASHTO,'value')
    Parameters.Beam.Type = 'AASHTO';
else
    Parameters.Beam.Type = 'BulbTee';
end

% % Determine appropriate section based on span length
% [Parameters, exitflagG] = GetPSGirder(Parameters);

% % Inform user if unable to find appropriate section
% if ~exitflagG
%     fprintf('\nUnable to find section adequate for specified span length\n')
%     return
% end

contents = cellstr(get(handles.listboxSections,'string'));
Section = contents{get(handles.listboxSections,'Value')};
if ~strcmp(Section,'Custom')
    [Parameters.Beam,Parameters.Beam.Section] = PSSectionChoose(Section,Parameters.Beam);
else
    [Parameters] = CustomPSSection(Parameters,handles);
end

Parameters.GirderSpacing = str2double(get(handles.editGirderSpacing, 'String'));
Parameters.NumGirder = str2double(get(handles.editNumGirder, 'String'));

Parameters.Beam.RFSteelCheck = get(handles.CompSteelcheck,'Value');

Parameters = GetStructureConfig([], Parameters, [], Options);

Parameters.Design.DesignLoad = 'A';
Parameters.Design.Code = 'LRFD';
Parameters.Design = GetTruckLoads(Parameters.Design);
Parameters = AASHTODesign(Parameters);
% % Calculate Section Forces
% Parameters = PSSectionForces(Parameters);

[Parameters, PSexitflag] = PSGirderDesign(Parameters);

% if PS design fails prompt for larger girder section
if ~PSexitflag
    fprintf('Design failed. Specify different girder section');
    return
end

% Save data to appdata
setappdata(0,'Options',Options);
setappdata(0,'Parameters',Parameters);

% Display design on UI
set(handles.textPSNum,'string',Parameters.Beam.PSSteel.NumStrands);
set(handles.editPSCG,'string',Parameters.Beam.PSCenter);
diaind = find(Parameters.Beam.PSSteel.d==[.250 .313 .375 .438 .500 .520 .563 .600 .700]);
set(handles.pmDia,'value',diaind);

if Parameters.Beam.RFSteelCheck || Parameters.Beam.RFSteel.A~=0
set(handles.editNoBars,'string',Parameters.Beam.RFSteel.NumBars);
barind = find(Parameters.Beam.RFSteel.BarNo==[3 4 5 6 7 8 9 10 11 14 18]);
set(handles.popupBarNo,'value',barind)
set(handles.editCGCompSteel,'string',Parameters.Beam.RFCenter);
end



% --- Executes on button press in checkboxComposite_Sidewalk.
function checkboxComposite_Sidewalk_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxComposite_Sidewalk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxComposite_Sidewalk


% --- Executes on button press in checkboxComposite_Barrier.
function checkboxComposite_Barrier_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxComposite_Barrier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxComposite_Barrier


% --- Executes on button press in checkboxComposite_Deck.
function checkboxComposite_Deck_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxComposite_Deck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxComposite_Deck



function editGirderSpacing_Callback(hObject, eventdata, handles)
if ~isempty(get(handles.editNumGirder, 'String')) 
    set(handles.txtTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
end


% --- Executes during object creation, after setting all properties.
function editGirderSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGirderSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumGirder_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

Parameters.NumGirder = str2double(get(hObject, 'String'));

if ~isempty(get(handles.editGirderSpacing, 'String')) 
    set(handles.txtTotalWidth, 'String',...
        str2double(get(handles.editGirderSpacing, 'String'))*...
        (str2double(get(handles.editNumGirder, 'String'))-1));
end

% --- Executes during object creation, after setting all properties.
function editNumGirder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumGirder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMaxSpantoDepth_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxSpantoDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaxSpantoDepth as text
%        str2double(get(hObject,'String')) returns contents of editMaxSpantoDepth as a double


% --- Executes during object creation, after setting all properties.
function editMaxSpantoDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxSpantoDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textPSNum_Callback(hObject, eventdata, handles)
% hObject    handle to textPSNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textPSNum as text
%        str2double(get(hObject,'String')) returns contents of textPSNum as a double



function editPSCG_Callback(hObject, eventdata, handles)
% hObject    handle to editPSCG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPSCG as text
%        str2double(get(hObject,'String')) returns contents of editPSCG as a double


% --- Executes when selected object is changed in uipSectionType.
function uipSectionType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipSectionType 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
Parameters = getappdata(0,'Parameters');
switch get(hObject,'string')
    case 'AASHTO'
        % Assign List of Prestressed Sections
        Sections = {'AASHTO Type I'; 'AASHTO Type II'; 'AASHTO Type III';'AASHTO Type IV'; 'AASHTO Type V'; 'AASHTO Type VI'; 'Custom'};
        set(handles.listboxSections,'string',Sections);
        Parameters.Beam.Type = 'AASHTO';
        
    case 'Bulb-Tee'
        % Assign List of Prestressed Sections
        Sections = {'Bulb-Tee 54'; 'Bulb-Tee 63'; 'Bulb-Tee 72'; 'Custom'};
        set(handles.listboxSections,'string',Sections);
        Parameters.Beam.Type = 'BulbTee';
end

% Determine appropriate section based on span length
[Parameters, exitflagG] = GetPSGirder(Parameters);

% Inform user if unable to find appropriate section
if ~exitflagG
    fprintf('\nUnable to find section adequate for specified span length\n')
    return
end

% Set selection
switch get(hObject,'string')
    case 'AASHTO'
        set(handles.listboxSections,'Value',str2double(Parameters.Beam.Name(end)));
    case 'Bulb-Tee'
        switch Parameters.Beam.Name(end-1:end)
            case '54'
                set(handles.listboxSections,'Value',1);
            case '63'
                set(handles.listboxSections,'Value',2);
            case '72'
                set(handles.listboxSections,'Value',3);
        end
end

%Set section dimensions
DimHandles = [handles.editD handles.editbf handles.edit_bfb handles.edit_tft handles.edit_tfb handles.edit_tw...
    handles.edit_d1 handles.edit_d2 handles.edit_d3 handles.edit_b1 handles.edit_b2 handles.edit_b3];
[~, Dims] = PSSectionChoose(Parameters.Beam.Name, Parameters.Beam);
set(handles.editD,'string',Dims(1))
set(handles.editbf,'string',Dims(7))
set(handles.edit_bfb,'string',Dims(8))
set(handles.edit_tft,'string',Dims(2))
set(handles.edit_tfb,'string',Dims(6))
set(handles.edit_tw,'string',Dims(9))
set(handles.edit_d1,'string',Dims(3))
set(handles.edit_d2,'string',Dims(4))
set(handles.edit_d3,'string',Dims(5))
set(handles.edit_b1,'string',Dims(14))
set(handles.edit_b2,'string',Dims(15))
set(handles.edit_b3,'string',Dims(16))
set(DimHandles,'style','text');

setappdata(0,'Parameters',Parameters);
    


% --- Executes during object creation, after setting all properties.
function uipSectionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipSectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in pmDia.
function pmDia_Callback(hObject, eventdata, handles)
% hObject    handle to pmDia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmDia contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmDia


% --- Executes during object creation, after setting all properties.
function pmDia_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmDia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNoBars_Callback(hObject, eventdata, handles)
% hObject    handle to editNoBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNoBars as text
%        str2double(get(hObject,'String')) returns contents of editNoBars as a double


% --- Executes during object creation, after setting all properties.
function editNoBars_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNoBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCGCompSteel_Callback(hObject, eventdata, handles)
% hObject    handle to editCGCompSteel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCGCompSteel as text
%        str2double(get(hObject,'String')) returns contents of editCGCompSteel as a double


% --- Executes during object creation, after setting all properties.
function editCGCompSteel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCGCompSteel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupBarNo.
function popupBarNo_Callback(hObject, eventdata, handles)
% hObject    handle to popupBarNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupBarNo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBarNo


% --- Executes during object creation, after setting all properties.
function popupBarNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBarNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CompSteelcheck.
function CompSteelcheck_Callback(hObject, eventdata, handles)
CompSteel = get(hObject,'value');
subH = allchild(handles.uipanelCompSteel);
if CompSteel    
    set(subH,'enable','on');
else
    set(subH,'enable','off');
end
    
% Hint: get(hObject,'Value') returns toggle state of CompSteelcheck
