function varargout = BearingSensitivity_gui(varargin)
% BEARINGSENSITIVITY_GUI MATLAB code for BearingSensitivity_gui.fig
%      BEARINGSENSITIVITY_GUI, by itself, creates a new BEARINGSENSITIVITY_GUI or raises the existing
%      singleton*.
%
%      H = BEARINGSENSITIVITY_GUI returns the handle to a new BEARINGSENSITIVITY_GUI or the handle to
%      the existing singleton*.
%
%      BEARINGSENSITIVITY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEARINGSENSITIVITY_GUI.M with the given input arguments.
%
%      BEARINGSENSITIVITY_GUI('Property','Value',...) creates a new BEARINGSENSITIVITY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BearingSensitivity_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BearingSensitivity_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BearingSensitivity_gui

% Last Modified by GUIDE v2.5 12-Sep-2014 16:16:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BearingSensitivity_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @BearingSensitivity_gui_OutputFcn, ...
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


% --- Executes just before BearingSensitivity_gui is made visible.
function BearingSensitivity_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BearingSensitivity_gui (see VARARGIN)

% Choose default command line output for BearingSensitivity_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Creation Functions ------------------------------------------------------
Parameters = getappdata(0,'Parameters');
% popup box
bearingList = {'Fix', 'Exp', 'Both'};
nameList = {'U1', 'U2', 'U3', 'R1', 'R2', 'R3', 'Align'}; 
n = 0;
for i = 1:7
    if Parameters.Bearing.Linked(i)
        n = n+1;
        String{n} = [bearingList{3} '-' nameList{i}];
        springVal(n) = 14+i;
    else
        if Parameters.Bearing.Fixed.Update(i)
            n = n+1;
            String{n} = [bearingList{1} '-' nameList{i}];
            springVal(n) = i;
        end
        
        if Parameters.Bearing.Expansion.Update(i)
            n = n+1;
            String{n} = [bearingList{2} '-' nameList{i}];
            springVal(n) = 7+i;
        end
    end
end

% modeNum list - List modeNums 1-10
Data = cell(10,2);
for i=1:10
    Data{i,1} = i;
end
Data(:,2) = {false};
set(handles.uitableRunModes, 'Data', Data);

% Housekeeping
n = length(springVal);
paraList = struct('Alphas',cell(n,1),'freq',cell(n,1),'MAC',cell(n,1),...
                  'ratingSv2',cell(n,1),'ratingSt1',cell(n,1),'COMAC',cell(n,1));

semilogy(handles.axesGraph, [-5 5], [0.1 1000]); %set up graph as loglog plot

setappdata(handles.guiBearingSensitivity, 'paraList', paraList);
setappdata(handles.guiBearingSensitivity, 'springVal', springVal);
set(handles.popupParameter, 'String', String);

function varargout = BearingSensitivity_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% Pushbuttons -------------------------------------------------------------
function pushbtnRunSensitivityStudy_Callback(hObject, eventdata, handles)
Type = 'Dynamic';

SensitivityStudy(Type, handles) 

function pushbtnRunRatingStudy_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');

% Get Rating Code
ASDcheck = get(handles.radiobtnCode_ASD, 'value');

if ASDcheck
    Parameters.Rating.Code = 'ASD';
else
    Parameters.Rating.Code = 'LRFD';
end

% Get Rating Truck
Trucks = get(handles.popupRatingTruck,'string');
selectInd = get(handles.popupRatingTruck,'value');

Parameters.Rating.DesignTruckName = Trucks(selectInd);
if ASDcheck
    Parameters.Rating.DesignLoad = num2str(selectInd);
else
    Parameters.Rating.DesignLoad = 'A';
end

Parameters.Rating = GetTruckLoads(Parameters.Rating);

%% Get Lane width
if ~isfield(Parameters,'NumLane')
    Parameters.NumLane = floor(Parameters.RoadWidth/144);
end

%Write to root
setappdata(0,'Parameters',Parameters);

% Get Node and Options structures from root
Node = getappdata(0,'Node');
Options = getappdata(0,'Options');
uID = 1;

%% Run Load Rating Functions in loop
Type = 'Rating';

SensitivityStudy(Type, handles) 

function pushbtnApplyBounds_Callback(hObject, eventdata, handles)
paraList = getappdata(handles.guiBearingSensitivity, 'paraList');

% get current parameter
value = get(handles.popupParameter, 'Value');

% apply bounds from paralist to edit fields and data structure
% get min and max fields
lbAlpha = str2double(get(handles.editLowerBound, 'String'));
ubAlpha = str2double(get(handles.editUpperBound, 'String'));
avg = str2double(get(handles.editMean, 'String'));
% Apply to edit fields
set(handles.editMin, 'String', num2str(lbAlpha));
set(handles.editMax, 'String', num2str(ubAlpha));
% Apply to paraList data structure
paraList(value).Alphas.lb = lbAlpha;
paraList(value).Alphas.ub = ubAlpha;
paraList(value).Alphas.avg = avg;

% set app data
setappdata(handles.guiBearingSensitivity,'paraList',paraList);

function pushbtnAcceptBounds_Callback(hObject, eventdata, handles)
% accept bounds as alpha values for correlation and make mean value alpha=1
% apply bounds from paralist to parameters spring values and alpha values
paraList = getappdata(handles.guiBearingSensitivity, 'paraList');
Parameters = getappdata(0,'Parameters');
springVal = getappdata(handles.guiBearingSensitivity, 'springVal');

for i=1:length(springVal)
    if isfield(paraList(i).Alphas,'avg')
        if springVal(i) <= 7 % fixed
            
            Parameters.Bearing.Fixed.Spring(springVal(i)) = Parameters.Bearing.Fixed.Spring(springVal(i))*10^paraList(i).Alphas.avg;
            
            Parameters.Bearing.Fixed.Alpha(springVal(i),2) = paraList(i).Alphas.lb-paraList(i).Alphas.avg;
            Parameters.Bearing.Fixed.Alpha(springVal(i),3) = paraList(i).Alphas.ub-paraList(i).Alphas.avg;
            Parameters.Bearing.Fixed.Alpha(springVal(i),1) = 0;
        elseif springVal(i) <= 14 % expansion
            
            Parameters.Bearing.Expansion.Alpha(springVal(i)-7,2) = paraList(i).Alphas.lb-paraList(i).Alphas.avg;
            Parameters.Bearing.Expansion.Alpha(springVal(i)-7,3) = paraList(i).Alphas.ub-paraList(i).Alphas.avg;
            Parameters.Bearing.Expansion.Alpha(springVal(i)-7,1) = 0;
            
            Parameters.Bearing.Expansion.Spring(springVal(i)-7) = Parameters.Bearing.Expansion.Spring(springVal(i)-7)*10^paraList(i).Alphas.avg;
        else % both
            Parameters.Bearing.Fixed.Alpha(springVal(i)-14,2) = paraList(i).Alphas.lb-paraList(i).Alphas.avg;
            Parameters.Bearing.Fixed.Alpha(springVal(i)-14,3) = paraList(i).Alphas.ub-paraList(i).Alphas.avg;
            Parameters.Bearing.Fixed.Alpha(springVal(i)-14,1) = 0;
            
            Parameters.Bearing.Fixed.Spring(springVal(i)-14) = Parameters.Bearing.Fixed.Spring(springVal(i)-14)*10^paraList(i).Alphas.avg;
            
            Parameters.Bearing.Expansion.Alpha(springVal(i)-14,2) = paraList(i).Alphas.lb-paraList(i).Alphas.avg;
            Parameters.Bearing.Expansion.Alpha(springVal(i)-14,3) = paraList(i).Alphas.ub-paraList(i).Alphas.avg;
            Parameters.Bearing.Expansion.Alpha(springVal(i)-14,1) = 0;
            
            Parameters.Bearing.Expansion.Spring(springVal(i)-14) = Parameters.Bearing.Expansion.Spring(springVal(i)-14)*10^paraList(i).Alphas.avg;
        end
    end
end
setappdata(0,'Parameters',Parameters);

% call close request
guiBearingSensitivity_CloseRequestFcn(handles.guiBearingSensitivity, eventdata, handles)

function guiBearingSensitivity_CloseRequestFcn(hObject, eventdata, handles)

delete(hObject);

% Popup boxes -------------------------------------------------------------
function popupParameter_Callback(hObject, eventdata, handles)
Parameters = getappdata(0,'Parameters');
paraList = getappdata(handles.guiBearingSensitivity,'paraList');
springVal = getappdata(handles.guiBearingSensitivity,'springVal');
modeNum = getappdata(handles.guiBearingSensitivity, 'modeNum');

% Get DOF values and put in edit boxes
value = get(handles.popupParameter, 'Value');
DOF = springVal(value);

% change output fields, etc.
if isempty(paraList(value).MAC) && isempty(paraList(value).ratingSt1)   
    % get default alpha values
    if springVal(value) <= 7
        lbAlpha = Parameters.Bearing.Fixed.Alpha(springVal(value),2);
        ubAlpha = Parameters.Bearing.Fixed.Alpha(springVal(value),3);
    elseif springVal(value) <= 14
        lbAlpha = Parameters.Bearing.Expansion.Alpha(springVal(value)-7,2);
        ubAlpha = Parameters.Bearing.Expansion.Alpha(springVal(value)-7,3);
    else
        lbAlpha = Parameters.Bearing.Fixed.Alpha(springVal(value)-14,2);
        ubAlpha = Parameters.Bearing.Fixed.Alpha(springVal(value)-14,3);
    end
    
    % change alpha edit fields
    set(handles.editMin, 'String', lbAlpha);
    set(handles.editMax, 'String', ubAlpha);
    
    cla(handles.axesGraph);
    cla(handles.axesRatingFactorSt);
    cla(handles.axesRatingFactorSv); 
    
    set(handles.editLowerBound, 'String', []);
    set(handles.editMean, 'String', []);
    set(handles.editUpperBound, 'String', []);
else
      % Get previous info
    stepAlpha = paraList(value).Alphas.stepAlpha;
    ubAlpha = paraList(value).Alphas.ub;
    lbAlpha = paraList(value).Alphas.lb;
    avgAlpha = paraList(value).Alphas.avg;
 
    % change alpha edit fields
    set(handles.editMin, 'String', num2str(lbAlpha));
    set(handles.editMax, 'String', num2str(ubAlpha));

    % Set text fields
    set(handles.editLowerBound, 'String', num2str(lbAlpha));
    set(handles.editMean, 'String', num2str(avgAlpha));
    set(handles.editUpperBound, 'String', num2str(ubAlpha));   
end

% change output fields, etc.
if ~isempty(paraList(value).MAC)
    COMAC = paraList(value).COMAC;
    MAC = paraList(value).MAC;
    freq = paraList(value).freq;

    hold off
    % plot freq for each modeNum
    semilogy(handles.axesGraph, stepAlpha, freq);
    xlim(handles.axesGraph, [lbAlpha ubAlpha]);
    ylim(handles.axesGraph, [.9*min(min(freq)) 1.1*max(max(freq))]);
    
    % plot MAC for first modeNum
    axes(handles.axesMACGrid);
    imagesc(MAC{value});
    
    % plot COMAC plot for first modeNum
    hist(handles.axesCOMAC, COMAC');
end

if ~isempty(paraList(value).ratingSt1)
    ratingSt1 = paraList(value).ratingSt1;
    ratingSv2 = paraList(value).ratingSv2;
    
    hold off
    % plot freq for each modeNum
    semilogy(handles.axesRatingFactorSt, stepAlpha, ratingSt1);
    xlim(handles.axesRatingFactorSt, [lbAlpha ubAlpha]);
    ylim(handles.axesRatingFactorSt, [.9*min(min(min(ratingSt1))) 1.1*max(max(max(ratingSt1)))]);
    
     % plot freq for each modeNum
    semilogy(handles.axesRatingFactorSv, stepAlpha, ratingSv2);
    xlim(handles.axesRatingFactorSv, [lbAlpha ubAlpha]);
    ylim(handles.axesRatingFactorSv, [.9*min(min(min(ratingSv2))) 1.1*max(max(max(ratingSv2)))]);
end


% Edit boxes -------------------------------------------------------------
function editMin_Callback(hObject, eventdata, handles)

function editMax_Callback(hObject, eventdata, handles)

function editNumPoints_Callback(hObject, eventdata, handles)

% Check boxes -------------------------------------------------------------
function uitableRunModes_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitableRunModes (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Switch graphs if modeNum number is selected in uitable
if eventdata.Indices(2) == 1;
    paraList = getappdata(handles.guiBearingSensitivity, 'paraList');
    value = get(handles.popupParameter, 'Value');
    modeNum = eventdata.Indices(1);
    
    axes(handles.axesMACGrid);
    try
        if ~isempty(paraList(value).MAC{modeNum}); % check to see if graphs have been created before 
            imagesc(paraList(value).MAC{modeNum}); % graph MAC plot
        end
    catch
        imagesc([]); % if not, just clear plots
    end
    
    setappdata(handles.guiBearingSensitivity, 'modeNum', modeNum);
end

% Axes --------------------------------------------------------------------
function axesGraph_ButtonDownFcn(hObject, eventdata, handles)
GraphButtonDown(hObject, handles)

function axesRatingFactorSv_ButtonDownFcn(hObject, eventdata, handles)
GraphButtonDown(hObject, handles)

function axesRatingFactorSt_ButtonDownFcn(hObject, eventdata, handles)
GraphButtonDown(hObject, handles)

function GraphButtonDown(hObject, handles)
% get current mouse position
pos = get(hObject, 'CurrentPoint');
xpos = pos(1,1);

% get min and max fields
lbAlpha = str2double(get(handles.editLowerBound, 'String'));
ubAlpha = str2double(get(handles.editUpperBound, 'String'));

% Find closest bound to click and replace bounds fields
if abs(xpos-ubAlpha) < abs(xpos-lbAlpha)
    set(handles.editUpperBound, 'String', num2str(xpos));
else
    set(handles.editLowerBound, 'String', num2str(xpos));
end

% Replace Mean values between new bounds
set(handles.editMean, 'String', num2str(mean([ubAlpha, lbAlpha])));


% Rating Factor Otions ----------------------------------------------------
function popupRatingTruck_Callback(hObject, eventdata, handles)

function radiobtnCode_ASD_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') % true
    set(handles.radiobtnCode_LRFD, 'Value', 0); % set opposite to false
    set(hObject, 'Value', 1); % set current to false
    LRFD = 0;
else    % false
    set(handles.radiobtnCode_LRFD, 'Value', 1); % set opposite to true
    set(hObject, 'Value', 0); % set current to false
    LRFD = 1;
end

SetDesignTruckList(LRFD, handles)
  
function radiobtnCode_LRFD_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') % true
    set(handles.radiobtnCode_ASD, 'Value', 0); % set opposite to false
    set(hObject, 'Value', 1); % set current to true
    LRFD = 1;
else    % false
    set(handles.radiobtnCode_ASD, 'Value', 1); % set opposite to true
    set(hObject, 'Value', 0); % set current to false
    LRFD = 0;
end

SetDesignTruckList(LRFD, handles)

function SetDesignTruckList(LRFD, handles)
% Design Trucks
tempcd = pwd;
cd('../');
load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList');
cd(tempcd);

if LRFD
    set(handles.popupRatingTruck,'String', {'HL-93'});
    set(handles.popupRatingTruck, 'Value', 1);
else
    set(handles.popupRatingTruck, 'String', DesignTruckList, 'Value', 6);
end

%% Sensitivity Study ------------------------------------------------------
function SensitivityStudy(Type, handles) 
h = waitbar(0.1, 'Running Sensitivity Study');
% Sensitivity ------------------------------------------------------------
Options = getappdata(0,'Options');
Node = getappdata(0,'Node');
Parameters = getappdata(0,'Parameters');

paraList = getappdata(handles.guiBearingSensitivity, 'paraList');
springVal = getappdata(handles.guiBearingSensitivity, 'springVal');

% get user values
value = get(handles.popupParameter, 'Value');
nIter = str2double(get(handles.editNumPoints, 'String'));

% get user alpha bounds and apply to text fields and local variable
% variable
lbAlpha = str2double(get(handles.editMin, 'String'));
ubAlpha = str2double(get(handles.editMax, 'String'));
% bounds text fields
set(handles.editLowerBound, 'String', num2str(lbAlpha));
set(handles.editUpperBound, 'String', num2str(ubAlpha));
set(handles.editMean, 'String', num2str(mean([ubAlpha, lbAlpha])));
% Place in paralist
paraList(value).Alphas.lb = lbAlpha;
paraList(value).Alphas.ub = ubAlpha;
paraList(value).Alphas.avg = mean([lbAlpha ubAlpha]);

% get modeNums to solve for
Data = get(handles.uitableRunModes, 'Data');
modeNums = find(cell2mat(Data(:,2)));

% get point discretization - linear scale!
stepAlpha = lbAlpha:(ubAlpha-lbAlpha)/(nIter-1):ubAlpha;
paraList(value).Alphas.stepAlpha = stepAlpha;

% Run nat freqs
% St7 modeNuml file is still open
modelPath = Options.St7.PathName;
modelName = Options.St7.FileName(1:end-4);

% check for num modeNums
Options.Analysis.NumModes = max(modeNums);

% decimate nodeList list of deck nodes until list is less than 100
nodeList = nonzeros(Node.ID(:,:,1));
while length(nodeList) > 100
    nodeList = nodeList(1:5:end);
end

% iterate
for i = 1:nIter
    waitbar(i/nIter, h);
    % get parameter to be changed
    if springVal(value) <= 7
        Parameters.Bearing.Fixed.Alpha(springVal(value),1) = stepAlpha(i);
    elseif springVal(value) <= 14
        Parameters.Bearing.Expansion.Alpha(springVal(value)-7,1) = stepAlpha(i);
    else
        Parameters.Bearing.Fixed.Alpha(springVal(value)-14,1) = stepAlpha(i);
        Parameters.Bearing.Expansion.Alpha(springVal(value)-14,1) = stepAlpha(i);
    end
    
    % apply new parameter step to modeNuml
    FCaseNum = 1;
    BoundaryConditions(Options.St7.uID, Node, Parameters, FCaseNum);
    
    switch Type
        case 'Dynamic'
            % run solver and get results
            St7RunNaturalFrequencySolver(Options.St7.uID, modelPath, modelName, Options);
            [St7Mode, St7Disp] = St7GetNaturalFrequencyResults(Options.St7.uID, modelPath, modelName, nodeList);
            
            % get frequencies of interest
            freq(:,i) = St7Mode(modeNums,1);
            shape(:,:,i) = St7Disp(:,modeNums);
            
            % Get MAC and COMAC
            MAC = cell(max(modeNums),1);
            n = 0;
            for i = min(modeNums):max(modeNums) % number of modeNums
                n = n+1;
                MAC{i} = GetMACValue(permute(shape(:,n,:),[1,3,2]),[]);
                COMAC(n,:) = GetCOMACValue(permute(shape(:,n,:),[1,3,2]),[]);
            end
        case 'Rating'
            % Call AASHTORatingFactors
            Parameters = AASHTOLoadRating(Parameters);
   
            % Check for existance of design Parameters
            if ~strcmp(Parameters.Design.Code, Parameters.Rating.Code)
                Parameters.Design.DesignLoad = Parameters.Rating.DesignLoad;
                Parameters.Design.Code = Parameters.Rating.Code;
                Parameters = AASHTODesign(Parameters);
                Parameters = GetSectionForces(Parameters);
                Parameters = GetLRFDResistance(Parameters);
            end
            
            % Run DeadLoad Solver and get results
            DeadLoadSolver(Options.St7.uID, modelName, modelPath, Node, Parameters);
            Parameters.Rating.DLR = DeadLoadResults(Options.St7.uID, modelPath, modelName, Node, Parameters);

            % Run Live Load Solver
            LiveLoadSolver(Options.St7.uID, Options, modelName, modelPath, Node, Parameters);
            Parameters.Rating.LLR = LiveLoadResults(Options.St7.uID, modelPath, modelName, Node, Parameters);
            
            Parameters = FEMRatingFactors(Parameters, Options, modelPath, modelName);
            
            ratingSt1(:,i) = min(Parameters.Rating.St1.RatingFactors_Op,[],3);
            ratingSv2(:,i) = min(Parameters.Rating.Sv2.RatingFactors_Op,[],3);
    end
end

% Graph after interation
switch Type
    case 'Dynamic'
        % --- PLots --------
        hold off
        % plot freq for each modeNum
        set(handles.axesGraph,'NextPlot','ReplaceChildren',...
            'ButtonDownFcn',{@axesGraph_ButtonDownFcn,handles},...
            'HitTest','on');
        semilogy(handles.axesGraph, stepAlpha, freq);
        set(get(handles.axesGraph,'Children'),'HitTest','off');
        xlim(handles.axesGraph, [lbAlpha ubAlpha]);
        ylim(handles.axesGraph, [.9*min(min(freq)) 1.1*max(max(freq))]);
        
        % plot MAC for first modeNum
        axes(handles.axesMACGrid);
        imagesc(MAC{1});
        
        % plot COMAC plot for first modeNum
        hist(handles.axesCOMAC, COMAC');
        
        % Save paraList info
        % Freq plot
        paraList(value).freq = freq;
        % MAC plots
        paraList(value).MAC = MAC;
        % CoMAC plot
        paraList(value).COMAC = COMAC;
    case 'Rating'
        % --- PLots --------
        hold off
        % plot freq for each modeNum
        set(handles.axesRatingFactorSt,'NextPlot','ReplaceChildren',...
            'ButtonDownFcn',{@axesRatingFactorSt_ButtonDownFcn,handles},...
            'HitTest','on');
        semilogy(handles.axesRatingFactorSt, stepAlpha, ratingSt1);
        set(get(handles.axesGraph,'Children'),'HitTest','off');
        xlim(handles.axesRatingFactorSt, [lbAlpha ubAlpha]);
        ylim(handles.axesRatingFactorSt, [.9*min(min(ratingSt1)) 1.1*max(max(ratingSt1))]);
        
        hold off
        % plot freq for each modeNum
        set(handles.axesRatingFactorSv,'NextPlot','ReplaceChildren',...
            'ButtonDownFcn',{@axesRatingFactorSv_ButtonDownFcn,handles},...
            'HitTest','on');
        semilogy(handles.axesRatingFactorSv, stepAlpha, ratingSv2);
        set(get(handles.axesGraph,'Children'),'HitTest','off');
        xlim(handles.axesRatingFactorSv, [lbAlpha ubAlpha]);
        ylim(handles.axesRatingFactorSv, [.9*min(min(ratingSv2)) 1.1*max(max(ratingSv2))]);
        
        % Save paraList info
        paraList(value).ratingSt1 = ratingSt1;
        paraList(value).ratingSv2 = ratingSv2;
end

close(h);

% Set Alpha value back to default
Parameters.Bearing.Fixed.Alpha(:,1) = 0;
Parameters.Bearing.Expansion.Alpha(:,1) = 0;
        
% Set app data
setappdata(0,'Options',Options);
setappdata(0,'Node',Node);
setappdata(0,'Parameters',Parameters);
setappdata(handles.guiBearingSensitivity, 'paraList',paraList);
