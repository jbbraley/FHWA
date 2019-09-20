function varargout = RAMPS_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RAMPS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @RAMPS_gui_OutputFcn, ...
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
function RAMPS_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for RAMPS_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% get data from root
Options = getappdata(0,'Options'); 

% Set overall handle data
Options.handles.RAMPS_gui = handles;

setappdata(0,'Options',Options);

function varargout = RAMPS_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function RAMPS_gui_CloseRequestFcn(hObject, eventdata, handles)
% Get options from app data to close and unload
Options = getappdata(0,'Options');
CloseAndUnload(Options.St7.uID);

% delete all GUI windows
allNames = fieldnames(getappdata(0));
guiNames = allNames(strncmp('OpenFig',allNames,7));
for i = 1:length(guiNames)
    if getfield(getappdata(0),guiNames{i}) ~= hObject % check to make sure arent deleting main gui
        delete(getfield(getappdata(0),guiNames{i}));
    end
end

delete(hObject);

RemoveAppData();

% Load Files --------------------------------------------------------------

function pushbtnNewModel_Callback(hObject, eventdata, handles)
global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU

hObject = handles.listboxNotificationPanel;
msg = 'Reseting RAMPS Model Workspace...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

try
    % Get app data
    Options = getappdata(0,'Options');
    
    %% Check for files and ask for name
    % Ask for file name and save dir
    [ModelName, ModelPath] = uiputfile([Options.SaveDir '*.st7'],'Choose Save Directory');
    % error screen no selection
    if all(ModelPath) == 0 || all(ModelName) == 0
        [~, ~] = FileLoadErrorHandling([], Options, handles);
        return
    end
    
    h = waitbar(0.2, 'Creating New St7 Model File...');
    
    % Check is model file is open
    if Options.FileOpen.St7Model
        % Close model file
        St7CloseModelFile(Options.St7.uID);
    end
    
    St7Start = 0;
    [Parameters, Options] = InitializeRAMPS([], [], St7Start);
    
    waitbar(0.4,h);
    
    % Set options
    Options.FileOpen.St7Model = 1;
    Options.FileOpen.Parameters = 1;
    Options.FileOpen.Options = 1;
    Options.PathName = ModelPath;
    Options.FileName = ModelName(1:end-4);
    
    % Clear Node. Reset and overwrite Options and Parameters
    if Options.FileOpen.Node
        clear('Nodes');
        rmappdata(0, 'Node');
    end
    Options.FileOpen.Node = 0;
    
    Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];
    
    St7NewModel(Options.St7.uID, Options.PathName, Options.FileName, Options.St7.ScratchPath, Units);
    
    %% Save files
    iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
    HandleError(iErr);
    
    waitbar(0.6,h);
    
    save([Options.PathName Options.FileName '_Para.mat'], 'Parameters', '-v7');
    save([Options.PathName Options.FileName '_Options.mat'], 'Options', '-v7');
    
    %% Call routine to save temp file
    Options = SaveTempFile(Options);
    
    %% Set data to root
    setappdata(0,'Options', Options);
    setappdata(0,'Parameters', Parameters);
    
    waitbar(0.8,h);
    
    %% Update GUI
    % update listbox string
    set(handles.listboxModelFile, 'string', [Options.PathName Options.FileName '.st7']);
    set(handles.listboxMetaData, 'string', [Options.PathName Options.FileName '_Para.mat']);
    
    State = 'Init';
    UpdateGeometryTables(Parameters,Options,State);
    UpdateDiaTables(Parameters,Options);
    
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
    
    close(h);
catch
    [~, ~] = FileLoadErrorHandling([], [], handles);
end

function pushbtnLoadModelFile_Callback(hObject, eventdata, handles)
try
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'Model Loading:...';
    type = 'new';
    UpdateNotificationPanel(hObject, msg, type);
    
    % Get data from root
    Options = getappdata(0, 'Options');
    Parameters = getappdata(0, 'Parameters');
    
    % Check if model is already open, if so, close it
    if Options.FileOpen.St7Model
        CloseModelFile(Options.St7.uID);
    end
    
    try
        % get files from user
        [filename, pathname] = uigetfile({'*.st7'  , 'All Files (*.st7)'}, ...
            'Select model file', ...
            'MultiSelect' , 'off');
    catch
        return
    end
    
    % error screen no selection
    if isempty(pathname) || isempty(filename)
        return
    end
    
    % Create full file name
    fullnames = {fullfile(pathname,filename)};
    
    % Define Model Name
    fname = filename(1:end-4);
    
    % Set model and path names to options
    Options.FileName = fname;
    Options.PathName = pathname;
    
    % Load St7 Files
    St7OpenModelFile(Options.St7.uID, Options.PathName, Options.FileName, Options.St7.ScratchPath)
    Options.FileOpen.St7Model = 1;
    
    % Save and open temp
    Options = SaveTempFile(Options);
    
    % set data to root
    setappdata(0, 'Options', Options);
    setappdata(0, 'Parameters', Parameters);
    
    % update listbox string
    set(handles.listboxModelFile, 'string', fullnames);
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = [fname '...DONE'];
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
    
    % Handle Metadata
    pushbtnLoadMetaData_Callback(handles.pushbtnLoadMetaData, eventdata, handles)
catch
   [~, ~] = FileLoadErrorHandling([], Options, handles);
end    

function pushbtnSaveModelFile_Callback(hObject, eventdata, handles)
try
    % get app data
    Options = getappdata(0, 'Options');
    
    % check if st7 model currently open
    if Options.FileOpen.St7Model
        % get files from user
        [FileName, PathName] = uiputfile({'*.*', 'All Files (*.*)'}, ...
            'Save model file', ...
            [Options.PathName Options.FileName '.st7']);
        
        % error screen no selection
        if isempty(PathName) || isetmpy(FileName)
            return
        end
        
        % Display metadata loading messages
        hObject = handles.listboxNotificationPanel;
        msg = 'Saving Model File...';
        type = 'new';
        UpdateNotificationPanel(hObject, msg, type);
        
        Options.FileName = FileName;
        Options.PathName = PathName;
        SaveTempFile(Options);
        
        % Display metadata loading messages
        hObject = handles.listboxNotificationPanel;
        msg = 'DONE';
        type = 'append';
        UpdateNotificationPanel(hObject, msg, type);
    else
        % Display metadata loading messages
        hObject = handles.listboxNotificationPanel;
        msg = 'FILE NOT OPEN';
        type = 'append';
        UpdateNotificationPanel(hObject, msg, type);
        
        return
    end
catch
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function listboxModelFile_Callback(hObject, eventdata, handles)

function pushbtnLoadMetaData_Callback(hObject, eventdata, handles)
% Display metadata loading messages
hObject = handles.listboxNotificationPanel;
msg = 'Meta Data Loading...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

try
    % Get data from root
    Options = getappdata(0, 'Options');
    Parameters = getappdata(0, 'Parameters');
    testData = getappdata(0, 'testData');
    
    % Check for metadata
    % Check if filenames exist in directory
    % Try to get filename if it's loaded...if metadata was cleared you have
    % to pick fiels manually
    fname = Options.FileName;
    pathname = Options.PathName;
    
    if exist([pathname fname '_Para.mat'],'file')==2
        meta_fnames{1} = fullfile(pathname,[fname '_Para.mat']);
    end
    if exist([pathname fname '_Node.mat'],'file')==2
        meta_fnames{2} = fullfile(pathname,[fname '_Node.mat']);
    end
    
    % If corresponding meta files do not exist in directory prompt for
    % selection - ignores if already in workspace
    % If they exist, save app data
    if exist([pathname fname '_Para.mat'],'file')~=2 || exist([pathname fname '_Node.mat'],'file')~=2
        % Ask for files
        [meta_filename, meta_pathname] = uigetfile({'*.mat'  , 'All Files (*.mat)'}, ...
            'Select files', ...
            'MultiSelect' , 'on');
        
        % Form cell array of filenames
        for ii = 1:length(meta_filename)
            meta_fnames{ii} = fullfile(meta_pathname, meta_filename{ii});
        end
    end
    
    % Load meta .mat files
    for ii = 1:length(meta_fnames)
        try
            load(meta_fnames{ii}); % load file
            
            % Set filenames and file open status to options
            if all(ismember('Para',meta_fnames{ii})) % checks what type of metadata
                Options.FileOpen.Parameters = 1;
                Options.FileNames.Parameters = meta_fnames{ii};
            elseif all(ismember('Node',meta_fnames{ii}))
                Options.FileOpen.Node = 1;
                Options.FileNames.Node = meta_fnames{ii};
            end
            
        catch
            if all(ismember('Para',meta_fnames{ii}))
                Options.FileOpen.Parameters = 0;
                Options.FileNames.Parameters = [];
            elseif all(ismember('Node',meta_fnames{ii}))
                Options.FileOpen.Node = 0;
                Options.FileNames.Node = [];
            end
        end
    end
            
    % Get model mesh data for display
    meshData = GetAnaMesh(Node);
    
    % Set filename and Pathname to Options in case loaded options file doesn't
    % match
    Options.FileName = fname;
    Options.PathName = pathname;
    
    % Save data to root
    setappdata(0,'Parameters',Parameters);
    setappdata(0,'Options',Options);
    setappdata(0,'meshData',meshData);
    
    % display file names
    set(handles.listboxMetaData, 'String', meta_fnames);
    
    % if all model files are open, run new natural frequency analysis
    if Options.FileOpen.Node && Options.FileOpen.St7Model
        % get freqs and mode shapes
        meshData = LoadNaturalFrequencyData(Options, meshData, meshData.nodeID(:,:,1)); % calls function to run solver, get results, and save data to meshData
        
        if ~isempty(testData)
            meshData = NaturalFrequencyComparison(Options, meshData, testData);
        end
       
        plotType = 'Ana';
        PlotModeShapes(plotType);
        PlotMAC(plotType);
        UpdateNatFreqTables();
    end
    
    % Update Geometry Info
    State = 'Init';
    UpdateGeometryTables(Parameters,Options,State);
    UpdateDiaTables(Parameters,Options);
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
catch
    % display file names
    set(handles.listboxMetaData, 'String', '');
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function pushbtnClearMetaData_Callback(hObject, eventdata, handles)
% Clear meta data files from memory
clear Parameters Options Node

% Remove app data
rmappdata(0, 'Parameters');
rmappdata(0, 'Options');
rmappdata(0, 'Node');
rmappdata(0, 'meshData');

% Clear meta data list box
msg = [];
set(handles.listboxMetaData, 'String', msg);

% Notification Panel
hObject = handles.listboxNotificationPanel;
msg = 'Meta Data Cleared.';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

% Reset Basic app data
St7Start = 0;
Options = [];
Parameters = [];
[Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

% set data to root
setappdata(0,'Parameters',Parameters);
setappdata(0,'Options',Options);

% Update Geometry Info
State = 'Init';
UpdateGeometryTables(Parameters,Options,State);
UpdateDiaTables(Parameters,Options);

        
function pushbtnSaveMetaData_Callback(hObject, eventdata, handles)
% Display metadata loading messages
hObject = handles.listboxNotificationPanel;
msg = 'Saving Meta Data...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

msg = [];
set(handles.listboxMetaData, 'String', msg);

try
    % get app data
    Options = getappdata(0, 'Options');
    
    % check if st7 model currently open
    if Options.FileOpen.Node
        % get Parameters and Node
        Node = getappdata(0, 'Node');
        
        % get files from user
        [filename, pathname] = uiputfile({'*.*', 'All Files (*.*)'}, ...
            'Save model file', ...
            [Options.PathName Options.FileName '_Node.mat']);
        
        % error screen no selection
        if ~pathname == 0
            % Save Node File
            save([pathname filename '_Node.mat'], 'Node');
        end
        
        % Put name in listbox
        set(handles.listboxMetaData, 'String', [pathname filename '_Node.mat']);
    end
    
    % check if st7 model currently open
    if Options.FileOpen.Parameters
        % get Parameters and Node
        Parameters = getappdata(0, 'Parameters');
        
        % get files from user
        [filename, pathname] = uiputfile({'*.*', 'All Files (*.*)'}, ...
            'Save model file', ...
            [Options.PathName Options.FileName '_Para.mat']);
        
        % error screen no selection
        if ~pathname == 0
            % Save Parameters File
            save([pathname filename], 'Parameters');
        end
        
        % Put name in listbox
        msg = cell(2,1);
        msg{1} = get(handles.listboxMetaData, 'String');
        if ~strcmp(msg{1},'')
            msg{2} = [pathname filename];
        else
            msg = [pathname filename];
        end
        set(handles.listboxMetaData, 'String', msg);
    end
    
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
    
catch
    % Display metadata loading messages
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function listboxMetaData_Callback(hObject, eventdata, handles)
metaName = get(hObject, 'String');
evalin('base',sprintf('load(''%s'')',metaName));

function pushbtnLoadTestData_Callback(hObject, eventdata, handles)
% Notification Panel
hObject = handles.listboxNotificationPanel;
msg = 'Test Data Loading...';
type = 'new';
UpdateNotificationPanel(hObject, msg, type);

try
    % Get data from root
    Options = getappdata(0, 'Options');
    
    % get files from user
    [filename, pathname] = uigetfile({'*.*'  , 'All Files (*.*)'}, ...
        'Select Test File', ...
        'MultiSelect' , 'off');
    
    % error screen no selection
    if pathname == 0
        return
    end
    
    % Create full file name
    fullnames = fullfile(pathname,filename);
    
    % Check if file is formatted or need to be imported
    loadRes = load(fullnames);
    if ~isfield(loadRes, 'testData') % not in imported format
        % Check for Metadata Files
        if ~Options.FileOpen.Parameters || ~Options.FileOpen.Node
            pushbtnLoadMetaData_Callback(handles.pushbtnLoadMetaData, eventdata, handles)
        end
        
        % import test data
        h = ImportTestData_gui(loadRes.results);
        waitfor(h);
        
        % Get full file name of formatted test data
        testFileName = getappdata(0, 'testFileName');
        testPathName = getappdata(0, 'testPathName');
        % rmeove from app data
        rmappdata(0, 'testFileName');
        rmappdata(0, 'testPathName');
        
        % load file
        loadRes = load(fullfile(testPathName,testFileName));
    end  
    testData = loadRes.testData;
    
    % update listbox string
    set(handles.listboxTestData, 'string', fullnames);
    
    % Set test data flag to open
    Options.FileOpen.TestData = 1;
    
    % Add all expModes to Options files
    Options.Correlation.expModes = 1:length(testData.freq);
    
    % get exp/exp MAC
    testData.MAC = GetMACValue(testData.U, testData.U);
    testData.COMAC = GetCOMACValue(testData.U, testData.U);
    
    % Set data to root
    setappdata(0,'Options',Options);
    setappdata(0,'testData',testData);
    
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'DONE';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type); 
    
    % Dynamic plots
    plotType = 'Exp';
    PlotModeShapes(Options.handles.guiModelExperimentComparison_gui, plotType);
    PlotMAC(Options.handles.guiModelExperimentComparison_gui,plotType);
    UpdateNatFreqTables(Options.handles.guiModelExperimentComparison_gui);

    % if all model files are open, run new natural frequency analysis
    if Options.FileOpen.Node && Options.FileOpen.St7Model
        meshData = getappdata(0,'meshData');
        
        % get freqs and mode shapes
        meshData = LoadNaturalFrequencyData(Options, meshData, meshData.nodeID); % calls function to run solver, get results, and save data to meshData
        meshData = NaturalFrequencyComparison(Options, meshData, testData);
        
        setappdata(0,'meshData', meshData);
        
        plotType = 'Ana';
        PlotModeShapes(Options.handles.guiModelExperimentComparison_gui, plotType);
        PlotMAC(Options.handles.guiModelExperimentComparison_gui,plotType);
        UpdateNatFreqTables(Options.handles.guiModelExperimentComparison_gui);
    end
catch
    % Set test data flag to open
    Options.FileOpen.TestData = 1;
    
    % Set data to root
    setappdata(0,'Options',Options);
    
    % Notification Panel
    hObject = handles.listboxNotificationPanel;
    msg = 'FAILED!';
    type = 'append';
    UpdateNotificationPanel(hObject, msg, type);
end

function listboxTestData_Callback(hObject, eventdata, handles)

% Notification Panel ------------------------------------------------------

function pushbtnClearNotificationPanel_Callback(hObject, eventdata, handles)
set(handles.guiSTIDPanel_gui, 'string', '');

function listboxNotificationPanel_Callback(hObject, eventdata, handles)

% Subfunction Buttons -----------------------------------------------------

% Build Model -------

function pushbtnNBIData_Callback(hObject, eventdata, handles)
NBIData_gui();

function pushbtnGeo_Callback(hObject, eventdata, handles)
UserInputDeck_gui();

function pushbtnDiaphragm_Callback(hObject, eventdata, handles)
SteelDiaSection_gui();

function pushbtnGirders_Callback(hObject, eventdata, handles)
SteelGirder_gui();

function pushbtnBuildFEM_Callback(hObject, eventdata, handles)
% Build Model
h = waitbar(0.2,'Please Wait While Bridge Model is Created...');

% Get data from root
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');

waitbar(0.4,h);

% Generate model
[Node, Parameters] = ModelGeneration(Options.St7.uID, Options, Parameters);

% Set Fileopn status
Options.FileOpen.Node = 1;

waitbar(0.6,h);

% Save file
iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

waitbar(0.8,h);

setappdata(0,'Parameters',Parameters);
setappdata(0,'Node',Node);

% Save meta data
pushbtnSaveMetaData_Callback(handles.pushbtnSaveMetaData, eventdata, handles)

close(h);

% Edit Model -------

function pushbtnBoundaryConditions_Callback(hObject, eventdata, handles)
UserInputBearings_Variable_gui();

function pushbtnParameters_Callback(hObject, eventdata, handles)
EditParameters_gui();

% StID -------------

function pushbtnTestModelComparison_Callback(hObject, eventdata, handles)
ModelExperimentComparison_gui();

function pushbtnParameterCorrelation_Callback(hObject, eventdata, handles)

function pushbtnRateModel_Callback(hObject, eventdata, handles)
LoadRating_gui();

% FE Model Window --

function pushbtnFEModelWindow_Callback(hObject, eventdata, handles)
FEModelWindow_gui();
