function varargout = ChooseExperimentalModeShapes_gui(varargin)
% CHOOSEEXPERIMENTALMODESHAPES_GUI MATLAB code for ChooseExperimentalModeShapes_gui.fig
%      CHOOSEEXPERIMENTALMODESHAPES_GUI, by itself, creates a new CHOOSEEXPERIMENTALMODESHAPES_GUI or raises the existing
%      singleton*.
%
%      H = CHOOSEEXPERIMENTALMODESHAPES_GUI returns the handle to a new CHOOSEEXPERIMENTALMODESHAPES_GUI or the handle to
%      the existing singleton*.
%
%      CHOOSEEXPERIMENTALMODESHAPES_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEEXPERIMENTALMODESHAPES_GUI.M with the given input arguments.
%
%      CHOOSEEXPERIMENTALMODESHAPES_GUI('Property','Value',...) creates a new CHOOSEEXPERIMENTALMODESHAPES_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseExperimentalModeShapes_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseExperimentalModeShapes_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseExperimentalModeShapes_gui

% Last Modified by GUIDE v2.5 07-May-2014 14:54:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseExperimentalModeShapes_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseExperimentalModeShapes_gui_OutputFcn, ...
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


% --- Executes just before ChooseExperimentalModeShapes_gui is made visible.
function ChooseExperimentalModeShapes_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseExperimentalModeShapes_gui (see VARARGIN)

% Choose default command line output for ChooseExperimentalModeShapes_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Natural Freq Analysis Settings
Options = getappdata(0,'Options');
set(handles.editNumAnaModes, 'String', num2str(Options.Analysis.NumModes));

% Load in blank coordData and testData
setappdata(handles.figureChooseExperimentalModeShapes, 'coordData', []);
setappdata(handles.figureChooseExperimentalModeShapes, 'testData', []);

function varargout = ChooseExperimentalModeShapes_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function figureChooseExperimentalModeShapes_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% File Dialogues ----------------------------------------------------------
function pushbtnLoadTestFile_Callback(hObject, eventdata, handles)
meshData = getappdata(handles.figureChooseExperimentalModeShapes,'meshData');
Options = getappdata(0,'Options');

% Get Test File
GetDir = 'E:\';
[FileName,PathName] = uigetfile([GetDir '*.mat'], 'Choose Test File');
load([PathName FileName]);
set(handles.editTestFileName, 'String', [PathName, FileName]); 

% fill freq chart
Data = cell(length(testData.freq), 2);
Data(:,2) = {true};
Data(:,1) = mat2cell(testData.freq, ones(length(testData.freq),1), 1);
set(handles.uitableExpFreq, 'Data', Data);

% Set num modes to 50% more than exp
Options.Analysis.NumModes = round(length(testData.freq)*1.5);
set(handles.editNumAnaModes, 'String', num2str(Options.Analysis.NumModes));

% Set slider bar max and min
set(handles.sliderChooseTestMode,...
    'Max', length(testData.freq),...
    'Min', 1,...
    'Value', 1,...
    'SliderStep', [1/(length(testData.freq)-1), 1/(length(testData.freq)-1)]);

% Load experimental data to appdata
setappdata(0,'testData', testData);

% Call slider callback
sliderChooseTestMode_Callback(handles.sliderChooseTestMode, eventdata, handles)

% Compute Exp/Exp MAC Value 
MAC = GetMACValue(testData.U, []);

% Plot MAC
axes(handles.axesExpExpMAC);
imagesc(MAC);

if ~isempty(meshData) % Compute Exp/Ana MAC
    % Pair exp and ana nodes
    N2.x = testData.coord(:,1);
    N2.y = testData.coord(:,2);
    N1.x = meshData.x;
    N1.y = meshData.y;
    pairedCoord = PairCoord(N1, N2);

    % Compute Exp/Exp MAC Value
    MAC = GetMACValue(testData.U, meshData.z(pairedCoord,:));
    
    % Plot MAC
    axes(handles.axesExpAnaMAC);
    imagesc(MAC);
end

setappdata(0,'Options',Options);

function editTestFileName_Callback(hObject, eventdata, handles)

function pushbtnLoadModelFiles_Callback(hObject, eventdata, handles)
Options = getappdata(0,'Options');
testData = getappdata(0,'testData');
Parameters = getappdata(0,'Parameters');

% Get File names to load
GetDir = 'E:\';
[FileName, PathName] = GetModelFiles(GetDir);

% Set Model File Name
set(handles.editModelFileName, 'String', [PathName{3}, FileName{3}]);

% Load Parameters File
load([PathName{1} FileName{1}]);

% Load nodes file 
load([PathName{2} FileName{2}]);

% Close existing model file and Load st7 file
if ~Options.modelOpen
    Options.modelOpen = 1;
    OpenModelFile(Options.St7.uID, PathName{3}, FileName{3}, Options.St7.ScratchPath);
else
    CloseModelFile(Options.St7.uID);
    Options.modelOpen = 1;
    OpenModelFile(Options.St7.uID, PathName{3}, FileName{3}, Options.St7.ScratchPath);
end
    
% Get x and y coords From Node.ID
for i=1:length(Node)
    nID{i} = nonzeros(Node(i).ID(:,:,1));
    X{i} = Node(i).x(nonzeros(Node(i).ID(:,:,1)));
    Y{i} = Node(i).y(nonzeros(Node(i).ID(:,:,1)));
end
meshData.nodeID = vertcat(nID{:});
meshData.x = vertcat(X{:})';
meshData.y = vertcat(Y{:})';

% Pair exp and ana nodes
N2.x = testData.coord(:,1);
N2.y = testData.coord(:,2);
N1.x = meshData.x;
N1.y = meshData.y;
pairedCoordIndex = PairCoord(N1, N2);
meshData.pairedCoord = meshData.nodeID(pairedCoordIndex);

% Run Natural Frequency Analysis
Options.Analysis.NumModes = str2double(get(handles.editNumAnaModes, 'String'));
Options.Analysis.ModeParticipation = 1;
ResultNodes = meshData.nodeID;
St7RunNaturalFrequencySolver(Options.St7.uID, PathName{3}, FileName{3}, Options);
[St7Mode, St7Disp] = St7GetNaturalFrequencyResults(Options.St7.uID, PathName{3}, FileName{3}, ResultNodes);

% Normalize St7 Mode Shapes
largest_val = (-min(St7Disp) < max(St7Disp)).*(max(St7Disp)-min(St7Disp))+min(St7Disp); 
St7Disp = bsxfun(@rdivide,St7Disp,largest_val);

% get z coords from St7Disp
meshData.z = St7Disp;

% Compute Exp/Exp MAC Value
MAC = GetMACValue(testData.U, meshData.z(pairedCoordIndex,:));

% Plot MAC
axes(handles.axesExpAnaMAC);
imagesc(MAC);

% Populate Analytical Frequency Table
Data = St7Mode(:,[1,5:10]);
Data(:,2:end) = round(Data(:,2:end)*100)*0.01;
set(handles.uitableAnaFreq, 'Data', Data);

meshData.freq = Data(:,1);

% Set slider bar max and min
set(handles.sliderChooseAnaMode,...
    'Max', size(St7Mode,1),...
    'Min', 1,...
    'Value', 1,...
    'SliderStep', [1/(size(St7Mode,1)-1), 1/(size(St7Mode,1)-1)]);

% set app data
Options.St7.PathName = PathName{3};
Options.St7.FileName = FileName{3};
setappdata(0, 'meshData', meshData);
setappdata(0, 'Options', Options);
setappdata(0, 'Parameters', Parameters);
setappdata(0, 'Node', Node);

% Call slider callback for 1st mode
sliderChooseAnaMode_Callback(hObject, eventdata, handles)

function editModelFileName_Callback(hObject, eventdata, handles)

% Sliders, Edit Fields, Tables---------------------------------------------
function sliderChooseTestMode_Callback(hObject, eventdata, handles)
testData = getappdata(0, 'testData');

% get slide value
slideVal(1) = get(handles.sliderChooseAnaMode, 'Value');
slideVal(2) = get(handles.sliderChooseTestMode, 'Value');

% Set Mode and Freq Text Boxes
set(handles.textExpMode, 'String', num2str(slideVal(2)));
set(handles.textExpFreq, 'String', num2str(testData.freq(slideVal(2))));

% set meshData to empty 
meshData = [];

% set scale
scale = 1;

% call plot function for exerpimental mode shapes
modeInterpGeneral(handles.axesExpModeShape, meshData, testData, slideVal, scale); 

% get actual current meshData
meshData = getappdata(0, 'meshData');

% call plot function to overlay experimental mode shapes onto analytical
modeInterpGeneral(handles.axesAnaModeShape, meshData, testData, slideVal, scale); 

% overlay exerimental mode shape on analytical data
function sliderChooseAnaMode_Callback(hObject, eventdata, handles)
testData = getappdata(0, 'testData');
meshData = getappdata(0, 'meshData');

% get slide values
slideVal(1) = get(handles.sliderChooseAnaMode, 'Value');
slideVal(2) = get(handles.sliderChooseTestMode, 'Value');

% Set Mode and Freq Text Boxes
set(handles.textAnaMode, 'String', num2str(slideVal(1)));
Data = get(handles.uitableAnaFreq, 'Data');
set(handles.textAnaFreq, 'String', num2str(Data(slideVal(1),1)));

% set scale 
scale = 1;

% call plot function to overlay experimental mode shapes onto analytical
modeInterpGeneral(handles.axesAnaModeShape, meshData, testData, slideVal, scale); 

function editNumAnaModes_Callback(hObject, eventdata, handles)

function uitableExpFreq_CellEditCallback(hObject, eventdata, handles)

% Accept and Run Analysis Buttons -----------------------------------------
function pushbtnAcceptFile_Callback(hObject, eventdata, handles)
% Get accepted data
Data = get(handles.uitableExpFreq, 'Data');

Options = getappdata(0,'Options');
Options.Correlation.expModes = find(cell2mat(Data(:,2))); %indeces in vector of true values
setappdata(0,'Options',Options);

% Get model files
figureChooseExperimentalModeShapes_CloseRequestFcn(handles.figureChooseExperimentalModeShapes, eventdata, handles)

% Utility Functions ------------------------------------------------------
function modeInterpGeneral(ah, meshData, testData, slideVal, scale)
if ~isempty(meshData) % if an coordinate system mesh is available, use that
    x = meshData.x;
    y = meshData.y;
    z = meshData.z(:,slideVal(1));
    
    tri = delaunay(x,y);
    
    hold(ah,'off');
    axes(ah);
    trimesh(tri,x,y,z);
    hold(ah,'on');
        
    if ~isempty(testData)
        validNode = ~isnan(testData.U(:,slideVal(2)));
        x = testData.coord(validNode,1);
        y = testData.coord(validNode,2);
        z = testData.U(validNode,slideVal(2));
        
        %overlay DOF in red
        plot3(ah,x,y,z,'marker','o',...
            'markerfacecolor','r',...
            'linestyle','none');
    end
    
    axis(ah,'fill');
    view(ah,-35,55)          % set axes proportional
    zlim(ah,[-1, 1]);
    
    hidden off
else
    validNode = ~isnan(testData.U(:,slideVal(2)));
    x = testData.coord(validNode,1);
    y = testData.coord(validNode,2);
    z = testData.U(validNode,slideVal(2));
    xb = testData.xb;
    yb = testData.yb;

    %concat geometry
    zb = zeros(length(xb),1);
    xTot = [x;xb];
    yTot = [y;yb];
    zTot = [z;zb];
    
    %define resolution
    xres = 35;
    yres = 35;
    
    %interp
    xv = linspace(min(xTot), max(xTot),xres);
    yv = linspace(min(yTot), max(yTot),yres);
    [xInterp,yInterp] = meshgrid(xv,yv);
    zInterp = griddata(xTot,yTot,zTot,xInterp,yInterp,'v4');
    
    %plot initial mesh
    hold(ah,'off');
    mesh(ah,xInterp,yInterp,zInterp);       %draw mesh
    hold(ah,'on');
    
    %overlay DOF in red
    plot3(ah,x,y,z,'marker','o',...
        'markerfacecolor','r',...
        'linestyle','none')
    
    %overlay boundaries in black
    plot3(ah,xb,yb,zb, 'marker','.',...
        'color','k',...
        'linestyle','none');
    
    axis(ah,'fill');
    view(ah,-35,55)
    zlim(ah,[-1, 1]);   % set axes proportional
    
    hidden off
end
