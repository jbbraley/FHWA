%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mass Redistribution 
% 09/18/2014
% David Masceri
%
% Runs mass redistribution of FE model to minimize differences in frequency
% and mode shape with experimental data.  LSQNONLIN is used as minimization
% algorithm.  Objective function is least squares sum of the squares of 
% vector of MAC values and percent frequency difference.
%
% Change Log --------------------------------------------------------------
% v.0.1 - 09/18/2104 - Initial creaiton of program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = MassRedistributionCheck_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MassRedistributionCheck_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @MassRedistributionCheck_gui_OutputFcn, ...
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

% Opening and Closing Functions -------------------------------------------
function MassRedistributionCheck_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Get App Data
Parameters = getappdata(0,'Parameters');
Options = getappdata(0,'Options');
meshData = getappdata(0,'meshData');
testData = getappdata(0,'testData');

%% Initial States
% Edit fields
set(handles.editNumModes, 'String', num2str(Options.Analysis.NumModes));
set(handles.editXDiv, 'String', '2', 'enable', 'on');
set(handles.editYDiv, 'String', '2', 'enable', 'on');
set(handles.uitableMass, 'ColumnEditable', [false, true]); %sets the inital mass alpha value as editable
set(handles.checkboxConstantTotalMass, 'Value', 0);
Options.Correlation.ConstantTotalMass = 0;
% Tables
setappdata(handles.guiMassRedistributionCheck_gui, 'lastExpRow', 1);
setappdata(handles.guiMassRedistributionCheck_gui, 'lastAnaRow', 1);


%% Natural Frequency and Mass Tables/Plots
% Frequency, Mode Shape, MAC, and COMAC
[meshData, MAC, COMAC] = DynamicsCalc(handles, Options, meshData, testData);
rePair = 1;
meshData = PairModes(Options, meshData, MAC, rePair); % Keep this initial paired throughout entire test 

%% set initial app data and correlation history
Parameters.CorrInit = [];
Parameters.CorrInit.Alpha{1} = ones(4,1);
Parameters.CorrInit.MAC{1} = MAC;
Parameters.CorrInit.COMAC{1} = COMAC;
Parameters.CorrInit.anaFreq{1} = meshData.freq(:,1);
Parameters.CorrInit.anaModes{1} = meshData.z;
Parameters.CorrInit.pairedModes{1} = meshData.pairedModes;
Parameters.CorrInit.pairedMAC{1} = meshData.pairedMAC;
Parameters.CorrInit.obj{1}(:,1) = ((meshData.freq(meshData.pairedModes(:,2),1)-testData.freq(meshData.pairedModes(:,1)))./testData.freq(meshData.pairedModes(:,1)));
Parameters.CorrInit.obj{1}(:,2) = meshData.pairedMAC;
Parameters.CorrInit.objFun{1} = sqrt(sum(vertcat(Parameters.CorrInit.obj{end}(:,1),Parameters.CorrInit.obj{end}(:,2)).^2));
CorrHistory = Parameters.CorrInit;

setappdata(0, 'Options', Options);
setappdata(0, 'Parameters', Parameters);
setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);
setappdata(handles.guiMassRedistributionCheck_gui, 'meshData', meshData);
setappdata(handles.guiMassRedistributionCheck_gui, 'lastAnaRow', 1);
setappdata(handles.guiMassRedistributionCheck_gui, 'lastExpRow', 1);
setappdata(handles.guiMassRedistributionCheck_gui,'zoneNodes',[]);
setappdata(handles.guiMassRedistributionCheck_gui,'zoneMass',[]);

%% Initial Plots
DynamicsPlot(handles);
% ModePlot(handles);
% Mass %, Redistribution
state = 'init';
MassPlot(handles, state);


function varargout = MassRedistributionCheck_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% Division Edit Fields ----------------------------------------------------
function editXDiv_Callback(hObject, eventdata, handles)
% Get App Data
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');

xDiv = str2num(get(hObject, 'String'));
yDiv = str2num(get(handles.editYDiv, 'String'));

CorrHistory.Alpha{1} = ones(xDiv*yDiv,1);
setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);

% Set State to Initial
state = 'init';

% Call mass plot 
MassPlot(handles, state);

function editYDiv_Callback(hObject, eventdata, handles)
% Get App Data
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');

yDiv = str2num(get(hObject, 'String'));
xDiv = str2num(get(handles.editXDiv, 'String'));

CorrHistory.Alpha{1}  = ones(xDiv*yDiv,1);
setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);

% Set State to Initial
state = 'init';

% Call mass plot 
MassPlot(handles, state);

function checkboxConstantTotalMass_Callback(hObject, eventdata, handles)
Options = getappdata(0, 'Options');
Data = get(handles.uitableMass, 'Data');
totalMass = sum(cell2mat(Data(:,2)));
numZones = size(Data,1);

if get(hObject, 'Value') % true - constant total mass
    Options.Correlation.ConstantTotalMass = 1;
    
    if totalMass ~= numZones
        Data(:,2) = mat2cell(ones(numZones,1), ones(numZones,1));
        set(handles.uitableMass, 'Data', Data);
        drawnow
    end
else
    Options.Correlation.ConstantTotalMass = 0;
end

setappdata(0, 'Options', Options);

function editNumModes_Callback(hObject, eventdata, handles)

% Buttons --------------------------------------------------------------
function pushbtnRun_Callback(hObject, eventdata, handles)
% Get app data
Options = getappdata(0,'Options');

% Check total mass
if Options.Correlation.ConstantTotalMass
    Data = get(handles.uitableMass, 'Data');
    totalMass = sum(cell2mat(Data(:,2)));
    numZones = size(Data,1);
    if totalMass ~= numZones
        Data(:,2) = mat2cell(ones(numZones,1), ones(numZones,1));
        set(handles.uitableMass, 'Data', Data);
        drawnow
    end
end

% Get number of ana modes to use
Options.Correlation.numAnaModes = str2num(get(handles.editNumModes,'String'));

% Set app data
setappdata(0,'Options',Options);

% Call init for MassPlot to set up everything
state = 'init';
MassPlot(handles, state)

% Call function
MassRedistribution(handles);

function pushbtnSave_Callback(hObject, eventdata, handles)
Options = getappdata(0, 'Options');
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');

[fname, pname] = uiputfile([Options.St7.PathName '\' Options.St7.FileName(1:end-4) '_masscheck.mat'], 'Save Mass Check History As');

if ~isempty(fname)
    save([pname '\' fname],'CorrHistory');
end

% Calculation Functions ---------------------------------------------------
function [meshData, MAC, COMAC] = DynamicsCalc(handles, Options, meshData, testData, CorrHistory) % Get nat freq and mode shapes for model
%% Calculate dynamic properties
corrModes = Options.Correlation.expModes;

% Set St7 Nat Freq options
Options.Analysis.ModeParticipation = 0;
ResultNodes = meshData.pairedCoord;
% Run Solver
St7RunNaturalFrequencySolver(Options.St7.uID, Options.St7.PathName, Options.St7.FileName, Options);
% Get results
[meshData.freq, meshData.z] = St7GetNaturalFrequencyResults(Options.St7.uID, Options.St7.PathName, Options.St7.FileName, ResultNodes);
meshData.z = NormalizeModeShapes(meshData.z);
% Calculate COMAC for each mode pair
COMAC = GetCOMACValue(testData.U(:,corrModes), meshData.z(:,corrModes));
% Calculate MAC values
MAC = GetMACValue(testData.U, meshData.z);

function meshData = PairModes(Options, meshData, MAC, rePair) 
%% get frequency pairs
%%%%%%% Don't Enforce Mode Order %%%%%%
numCorrMode = length(Options.Correlation.expModes);
numAnaMode = size(meshData.freq,1);
corrMode = Options.Correlation.expModes;
C = zeros(numCorrMode,1);
I = zeros(numCorrMode,2);
I(:,1) = Options.Correlation.expModes;
MACsearchindex=1:numAnaMode;

if rePair 
    for i=1:numCorrMode
        % Find index of max MAC value for current experimental frequency
        % Use this to pair exp to analytical frequency
        [~,ind] = max(MAC(corrMode(i),MACsearchindex),[],2);
        I(i,2) = MACsearchindex(ind);
        C(i) = MAC(corrMode(i),MACsearchindex(ind));
        % Subtract out analytical mode vector from MAC search index so it cannot be
        % paired with any other experimental mode
        MACsearchindex(ind)=[];
    end
    
    meshData.pairedModes = I;
else
    IND = sub2ind(size(MAC),meshData.pairedModes(:,1),meshData.pairedModes(:,2));
    C = MAC(IND); 
end

meshData.pairedMAC = C;

% Plot and Table Functions ------------------------------------------------
function DynamicsPlot(handles)
%% Get App Data
testData = getappdata(0, 'testData');
meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');
Options = getappdata(0, 'Options');

%% Variable Assignmnets
numExpFreq = length(testData.freq(:,1));
numCorrFreq = length(Options.Correlation.expModes);
numAnaFreq = length(CorrHistory.anaFreq{end});
expFreq = testData.freq(:,1);
corrFreq = Options.Correlation.expModes;
anaFreq = CorrHistory.anaFreq{end};
pairedAnaModes = CorrHistory.pairedModes{end}(:,2);
expModes = Options.Correlation.expModes;
pairedMAC = CorrHistory.pairedMAC{end};
MAC = CorrHistory.MAC{end};
obj = CorrHistory.obj;
objFun = CorrHistory.objFun;
freqRes = [];
MACRes = [];
for i=1:size(obj,2)    
    freqRes = horzcat(freqRes,obj{:,i}(:,1));
    MACRes = horzcat(MACRes,obj{:,i}(:,2));
end

%% Freq Table
% get length and preallocate cell
Data = cell(numAnaFreq,2);
Data(:,1) = mat2cell(anaFreq(:,1), ones(numAnaFreq,1)); % analytical freqs
Data(1:numExpFreq,2) = mat2cell(expFreq, ones(numExpFreq,1));
% Populate Table
set(handles.uitableFreq, 'Data', Data); % convert freq array to individual cells

%% Freq Diff trend
if size(obj,2) > 1
    axes(handles.axesFrequencyNormalsPlot)
    plot(freqRes');
    set(handles.axesFrequencyNormalsPlot, 'XLim', [1,size(freqRes,2)]);
end

%% MAC table - max values for each exp mode
Data = cell(numExpFreq,4);
Data(corrFreq,1) = mat2cell(pairedMAC, ones(numCorrFreq,1));
Data(:,2) = mat2cell(expFreq, ones(numExpFreq,1));
Data(corrFreq,3) = mat2cell(anaFreq(pairedAnaModes), ones(numCorrFreq,1));
Data(corrFreq,4) = mat2cell(pairedAnaModes, ones(numCorrFreq,1));
percentDiff = 100*freqRes(:,end);
Data(corrFreq,5) = mat2cell(percentDiff, ones(numCorrFreq,1));
set(handles.uitableMAC, 'Data', Data);

%% MAC trend
if size(obj,2) > 1
    axes(handles.axesMACPlot)
    plot(MACRes');
    set(handles.axesMACPlot, 'XLim', [1,size(MACRes,2)]);
end

%% MAC
% Build 3-d colormap for MAC
RGB_high = colormap;
RGB_high_ind = ceil(MAC*length(RGB_high));
MAC_new = zeros(size(MAC,1), size(MAC,2), 3);
for i=1:size(MAC,1)
    for j=1:size(MAC,2)
        MAC_new(i,j,:) = RGB_high(RGB_high_ind(i,j),:);
    end
end
% add low saturation colors in unwanted mode rows
RGB_low = RGB_high;
HSV = rgb2hsv(RGB_high);
HSV_2 = 0.3*(rgb2hsv(RGB_high));
HSV(:,2) = HSV_2(:,2);
RGB_low = hsv2rgb(HSV);
RGB_low_ind = ceil(MAC*length(RGB_low));
for i=1:size(MAC,1)
    if i~=Options.Correlation.expModes
        for j=1:size(MAC,2)
            MAC_new(i,j,:) = RGB_low(RGB_low_ind(i,j),:);
        end
    end
end
axes(handles.axesMAC);
imagesc(MAC_new);

%% Objective Function
if size(objFun,2) > 1
    axes(handles.axesCOMAC)
    plot(cell2mat(objFun(1,:)));
    set(handles.axesMACPlot, 'XLim', [1,size(objFun,2)]);
end

function ModePlot(handles)
%% Get App Data
testData = getappdata(0, 'testData');
meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');
lastAnaRow = getappdata(handles.guiMassRedistributionCheck_gui, 'lastAnaRow');
lastExpRow = getappdata(handles.guiMassRedistributionCheck_gui, 'lastExpRow');

%% Plot experimental mode shape
x = meshData.x;
y = meshData.y;
z = CorrHistory.anaModes{end}(:,lastAnaRow);
    
tri = delaunay(x,y);

hold(handles.axesModeShapes,'off');
axes(handles.axesModeShapes);
trimesh(tri,x,y,z)
hold(handles.axesModeShapes,'on');

%% Overlay test nodes  
if ~isempty(testData)
    validNode = ~isnan(testData.U(:,lastExpRow));
    x = testData.coord(validNode,1);
    y = testData.coord(validNode,2);
    z = testData.U(validNode,lastExpRow);
    
    %overlay DOF in COMAC color
    hold(handles.axesModeShapes, 'on');
    colors = colormap;
    colorStep = length(colormap); % COMAC range = 0-1
    for i=1:length(x)
        %get comac index for colormap
        color = ceil(CorrHistory.COMAC{end}(i)*colorStep);
        % plot
        plot3(handles.axesModeShapes,x(i),y(i),z(i),'marker','o',...
            'markerfacecolor',colors(color,:),...
            'linestyle','none');
    end
    hold(handles.axesModeShapes, 'off');
end

%% Adjust axes
view(handles.axesModeShapes,-35,45)          % set axes proportional
zlim(handles.axesModeShapes,[-1, 1]);
xlim(handles.axesModeShapes,[-0.1*max(x),1.1*max(x)]);
ylim(handles.axesModeShapes,[-0.1*max(y),1.1*max(y)]);

hidden off

%% COMAC Plot
xb = testData.xb;
yb = testData.yb;

%concat geometry
zb = zeros(length(xb),1);
xTot = [x;xb];
yTot = [y;yb];
COMACTot = [CorrHistory.COMAC{end}(validNode);zb];

%define resolution
xres = 35;
yres = 35;

%interp
xv = linspace(min(xTot), max(xTot),xres);
yv = linspace(min(yTot), max(yTot),yres);
[xInterp,yInterp] = meshgrid(xv,yv);
COMACInterp = griddata(xTot,yTot,COMACTot,xInterp,yInterp,'v4');

%plot initial mesh
hold(handles.axesCOMAC,'off');
mesh(handles.axesCOMAC,xInterp,yInterp,COMACInterp);       %draw mesh
hold(handles.axesCOMAC,'on');

function MassPlot(handles, state)
% Get App Data
Parameters = getappdata(0, 'Parameters');
meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');
textHandle = getappdata(handles.guiMassRedistributionCheck_gui,'textHandle');
lineHandles = getappdata(handles.guiMassRedistributionCheck_gui,'lineHandles');

% check if before or during run
switch state
    case 'init'
        %% get division dimensions
        xDiv = str2num(get(handles.editXDiv, 'String'));
        yDiv = str2num(get(handles.editYDiv, 'String'));
        
        % get deck geometry
        [yR, yInd] = min(meshData.y);
        xNR = meshData.x(yInd);
        
        % Get Division points
        xDivLength = Parameters.Length/xDiv;
        yDivLength = Parameters.Width/yDiv;
        xDivPoints = zeros(xDiv+1,yDiv+1);
        yDivPoints = xDivPoints;
        for i = 1:xDiv+1
            for j = 1:yDiv+1
                if Parameters.SkewNear == Parameters.SkewFar
                    xDivPoints(i,j) = xNR + (i-1)*xDivLength + sign(Parameters.SkewNear)*(j-1)*yDivLength*tan(Parameters.SkewNear*pi/180);
                    yDivPoints(i,j) = yR + (j-1)*yDivLength;
                else
                    % Have to add this later
                end
            end
        end
        
        %% Draw divisions
        axes(handles.axesMassPlot); % sets current axes
        axis equal;   
        hold off
        % Delete old divisions
        if ~isempty(lineHandles)
            delete(lineHandles);
        end
        % reset lineHandles
        % ! Set z for lines to 1 to put on top of scatter points
        lineHandles = 0;
        n = 0;
        for i = 1:xDiv+1
            for j = 1:yDiv+1
                if i ~= xDiv+1
                    n = n + 1;
                    lineHandles(n) = line([yDivPoints(i,j),yDivPoints(i+1,j)],[xDivPoints(i,j),xDivPoints(i+1,j)],[1,1]);
                    set(lineHandles(n),'Color','k','LineWidth',2);
                end

                if j ~= yDiv+1
                    n = n + 1;
                    lineHandles(n) = line([yDivPoints(i,j),yDivPoints(i,j+1)],[xDivPoints(i,j),xDivPoints(i,j+1)],[1,1]);
                    set(lineHandles(n),'Color','k','LineWidth',2);
                end
            end 
        end
        
        %% get which points are in which division
        % build polygon vectors
        n = 0;
        xv = zeros(xDiv*yDiv,4);
        yv = xv;
        for i = 1:xDiv
            for j = 1:yDiv
                n = n + 1;
                xv(n,:) = [xDivPoints(i,j), xDivPoints(i+1,j), xDivPoints(i+1,j+1), xDivPoints(i,j+1)];
                yv(n,:) = [yDivPoints(i,j), yDivPoints(i+1,j), yDivPoints(i+1,j+1), yDivPoints(i,j+1)];
            end
        end
        % find which nodes are in each polygon
        nodeList = meshData.nodeID;
        zoneNodes = cell(n,1);
        for i = 1:n
            zoneNodes{i} = meshData.nodeID(inpolygon(meshData.x, meshData.y, xv(i,:), yv(i,:)));
            nodeList = nodeList(~ismember(nodeList, zoneNodes{i}));
        end
        % find where in the NodeID list each node number is
        nodeInd = cell(length(zoneNodes),1);
        hold on
        for i=1:length(zoneNodes)
            [~,nodeInd{i}] = ismember(zoneNodes{i},meshData.nodeID);
        end
              
        % Get mass per point in each division
        zoneMass = zeros(n,1);
        for i=1:n
            area = polyarea(xv(i,:)',yv(i,:)');
            zoneMass(i) = area/length(nodeInd{i})*Parameters.Deck.density*Parameters.Deck.t;
        end
        
          %% Plot zone labels
        if ~isempty(textHandle)
            delete(textHandle);
        end
        textHandle = [];
        for i = 1:n
            % Get centroid of zone
            xBar = (max(meshData.x(nodeInd{i})) + min(meshData.x(nodeInd{i})))/2;
            yBar = (max(meshData.y(nodeInd{i})) + min(meshData.y(nodeInd{i})))/2;
            
            % display text
            textCell = {num2str(i)};
            % NOTE: set ah as parent of text object
            textHandle(i) = text(yBar, xBar, 1, textCell, 'fontsize', 12, 'fontweight', 'bold',...
                            'parent',handles.axesMassPlot); % plot z as 1 to keep on top
        end
        
        %% plot mass points
        % check if previous points need to be cleared
        pointHandle = getappdata(handles.guiMassRedistributionCheck_gui,'pointHandle');
        if ~isempty(pointHandle)
            delete(pointHandle);
        end
        pointHandle = [];
        % plot
        hold on
        for i=1:n
            xPts = meshData.x(nodeInd{i});
            yPts = meshData.y(nodeInd{i});
            pointHandle(i) = scatter(yPts, xPts, 1*10^2, '.'); 
        end
        hold off
        
        % set axis reverse
        set(handles.axesMassPlot, 'XDir', 'reverse'); 
        
        %% Mass Table - equal division
        Data(:,1) = mat2cell((1:length(zoneMass))', ones(length(zoneMass),1));
        Data(:,2) = mat2cell(ones(length(zoneMass),1), ones(length(zoneMass),1));
        set(handles.uitableMass, 'Data', Data); % 4 initial zones
        
        %% set app data
        setappdata(handles.guiMassRedistributionCheck_gui,'lineHandles',lineHandles);
        setappdata(handles.guiMassRedistributionCheck_gui,'nodeInd',nodeInd);
        setappdata(handles.guiMassRedistributionCheck_gui,'zoneNodes',zoneNodes);
        setappdata(handles.guiMassRedistributionCheck_gui,'zoneMass',zoneMass);
        setappdata(handles.guiMassRedistributionCheck_gui,'pointHandle',pointHandle);
        setappdata(handles.guiMassRedistributionCheck_gui,'textHandle',textHandle);
    case 'iter'
        %% get app data
        zoneNodes = getappdata(handles.guiMassRedistributionCheck_gui,'zoneNodes');
        nodeInd = getappdata(handles.guiMassRedistributionCheck_gui,'nodeInd');
        Alpha = CorrHistory.Alpha{end};
        
        %% Disable editing 
        % for mass table
        set(handles.uitableMass, 'ColumnEditable', [false, false]); 
        % for divisions
        set(handles.editXDiv, 'enable', 'inactive');
        set(handles.editYDiv, 'enable', 'inactive');
        
        %% Plot Redistribution of Mass Points
        axes(handles.axesMassPlot);
        % clear previous points
        pointHandle = getappdata(handles.guiMassRedistributionCheck_gui,'pointHandle');
        delete(pointHandle);
        pointHandle = [];
        % plot
        hold on
        for i=1:length(zoneNodes)
            xPts = meshData.x(nodeInd{i});
            yPts = meshData.y(nodeInd{i});
            pointHandle(i) = scatter(yPts, xPts, CorrHistory.Alpha{end}(i)*10^2, '.');
        end
        hold off
             
        % set axis reverse
        set(handles.axesMassPlot, 'XDir', 'reverse');
        
        %% Plot Mass Trend
        % Plot mass trend
        axes(handles.axesMassTrend)
        plot(cell2mat(CorrHistory.Alpha)');
        if length(CorrHistory.Alpha)>1
            set(handles.axesMassTrend, 'XLim', [1,length(CorrHistory.Alpha)]);
        end
        
        % Populate mass % table
        Data(:,1) = mat2cell((1:length(Alpha))', ones(length(Alpha),1));
        Data(:,2) = mat2cell(Alpha, ones(length(Alpha),1));
        set(handles.uitableMass, 'Data', Data);
        drawnow
        
        setappdata(handles.guiMassRedistributionCheck_gui,'pointHandle',pointHandle);
        setappdata(handles.guiMassRedistributionCheck_gui,'textHandle',textHandle);
    case 'done'
        % Enable editing for mass table
        set(handles.uitableMass, 'ColumnEditable', [false, true]); 
        
        % Enablee editing for divisions
        set(handles.editXDiv, 'enable', 'on');
        set(handles.editYDiv, 'enable', 'on');       
end

% Table Callbacks ---------------------------------------------------------
function uitableFreq_CellSelectionCallback(hObject, eventdata, handles)
% get row and column
row = eventdata.Indices(1);
column = eventdata.Indices(2);

if column == 1 % analytical
    setappdata(handles.guiMassRedistributionCheck_gui, 'lastAnaRow', row);
else % column = 2, experimental
    setappdata(handles.guiMassRedistributionCheck_gui, 'lastExpRow', row);
end

% call function to change mode shape plot
% ModePlot(handles);

% Mass Redistribution Functions -------------------------------------------
function MassRedistribution(handles)
% Get App Data
% Get App Data
Parameters = getappdata(0, 'Parameters');
Options = getappdata(0, 'Options');
meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
testData = getappdata(0, 'testData');

% Least Squares non linear optimization of mass redistribution
% get zone info in app data
zoneNodes = getappdata(handles.guiMassRedistributionCheck_gui,'zoneNodes');
zoneMass = getappdata(handles.guiMassRedistributionCheck_gui,'zoneMass');
numZones = length(zoneMass); 

% Set deck mass to zero
Doubles = [Parameters.Deck.E 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', Options.St7.uID, 1, Doubles);
HandleError(iErr);

% Set Deck with initial mass
% initial Alpha values 
massMulti = cell2mat(get(handles.uitableMass, 'Data'));
Alpha = massMulti(:,2);

% Non structural mass distribution back to 1
dynFactor = [];
offsetList = [];
loadCase = 1;

nodeNum = [];
nsMass = [];
for i = 1:length(zoneMass)
    nodeNum = vertcat(nodeNum, zoneNodes{i});
    nsMass = vertcat(nsMass, zoneMass(i)*ones(length(zoneNodes{i}),1));
end
St7SetNonStructuralMass(Options.St7.uID, nodeNum, loadCase, nsMass, dynFactor, offsetList);

% Set up mass optimization function and options
% Tolerances
TolFun = 0.00001;
TolX = 0.001;
DiffMinChange = 0.0001;

% Output function definition
outfun = @(x,optimValues,state)OutputFunction(x, optimValues, state, handles, Parameters, Options);

% Options
options = optimset('Algorithm','trust-region-reflective','TolFun',TolFun,'TolX',TolX,...
    'Display','final','OutputFcn',outfun, 'DiffMinChange', DiffMinChange);


lB = zeros(numZones,1);
uB = length(zoneNodes)*ones(length(zoneNodes),1);

if ~Options.Correlation.ConstantTotalMass
    % Objective function definition
    objfun = @(Alpha)MassRedistributionOptimization(Alpha, handles, Options, meshData, testData, zoneNodes, zoneMass);
    
    [Alpha, resnorm, residual, exitflag, output, lambda]...
        = lsqnonlin(objfun, Alpha, lB, uB, options);
else
    % Objective function definition
    objfun = @(Alpha)MassRedistributionOptimization(Alpha, handles, Options, meshData, testData, zoneNodes, zoneMass);
    con = @(Alpha)TotalMassCheck(Alpha);
    
    [xC,fvalC,exitflagC,outputC]...
        = fmincon(objfun, Alpha, [], [], [], [], lB, uB, con, options);
end

% Non structural mass distribution back to 1
dynFactor = [];
offsetList = [];
loadCase = 1;

nodeNum = [];
nsMass = [];
for i = 1:length(zoneMass)
    nodeNum = vertcat(nodeNum, zoneNodes{i});
    nsMass = vertcat(nsMass, zeros(length(zoneNodes{i}),1));
end

St7SetNonStructuralMass(Options.St7.uID, nodeNum, loadCase, nsMass, dynFactor, offsetList);

% Set deck mass to normal
Doubles = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', Options.St7.uID, 1, Doubles);
HandleError(iErr);

function [c, ceq] = TotalMassCheck(Alpha)
numZones = length(Alpha);
ceq = sum(Alpha) - numZones;
c = [];

function obj = MassRedistributionOptimization(Alpha, handles, Options, meshData, testData, zoneNodes, zoneMass)
uID = Options.St7.uID;
ExpFreq = testData.freq;
numCorrFreq = length(Options.Correlation.expModes);

%% Update Model
fprintf('Updating Model...');

% Non structural mass distribution
dynFactor = [];
offsetList = [];
loadCase = 1;

nodeNum = [];
nsMass = [];
for i = 1:length(zoneMass)
    nodeNum = vertcat(nodeNum, zoneNodes{i});
    nsMass = vertcat(nsMass, Alpha(i)*zoneMass(i)*ones(length(zoneNodes{i}),1));
end

St7SetNonStructuralMass(uID, nodeNum, loadCase, nsMass, dynFactor, offsetList);

fprintf('Done\n');

%% Obtain Frequencies and Modeshapes from St7 Model
fprintf('Getting Modal Analysis Data...');

% Nat Freq Analysis
[meshData, MAC, COMAC] = DynamicsCalc(handles, Options, meshData, testData);
St7Freq = meshData.freq(:,1);

fprintf('Done\n');

%% Pair Frequencies and Mode Shapes Based on MAC
fprintf('Calculating MAC and Objective Function...');

rePair = 1; %1 if you want to repair modes based on new MACs
meshData = PairModes(Options, meshData, MAC, rePair); % pair modes?

%% Calculate the objective function
res = zeros(numCorrFreq,2);
res(:,1)=((St7Freq(meshData.pairedModes(:,2))-ExpFreq(meshData.pairedModes(:,1)))./ExpFreq(meshData.pairedModes(:,1)));
res(:,2)=1-meshData.pairedMAC;

objFun = sqrt(sum(vertcat(abs(res(:,1)),res(:,2)).^2));

if Options.Correlation.ConstantTotalMass
    obj = objFun;
else
    obj = vertcat(abs(res(:,1)),res(:,2));
end

% Set app data
setappdata(handles.guiMassRedistributionCheck_gui, 'Alpha', Alpha);
setappdata(handles.guiMassRedistributionCheck_gui, 'meshData', meshData);
setappdata(handles.guiMassRedistributionCheck_gui, 'MAC', MAC);
setappdata(handles.guiMassRedistributionCheck_gui, 'COMAC', COMAC);
setappdata(handles.guiMassRedistributionCheck_gui, 'obj', res);
setappdata(handles.guiMassRedistributionCheck_gui, 'objFun', objFun);

function stop = OutputFunction(x, optimValues, state, handles, Parameters, Options)
CorrHistory = getappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory');
switch state
    case 'init'
        CorrHistory.Alpha = [];
        CorrHistory.MAC = [];
        CorrHistory.COMAC = [];
        CorrHistory.anaFreq = [];
        CorrHistory.anaModes = [];
        CorrHistory.pairedModes = [];
        CorrHistory.pairedMAC = [];
        CorrHistory.obj = [];
        CorrHistory.objFun = [];
        
        setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);    
    case 'iter'
        %get app data
        Alpha = getappdata(handles.guiMassRedistributionCheck_gui, 'Alpha');
        meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
        MAC = getappdata(handles.guiMassRedistributionCheck_gui, 'MAC');
        COMAC = getappdata(handles.guiMassRedistributionCheck_gui, 'COMAC');
        obj = getappdata(handles.guiMassRedistributionCheck_gui, 'obj');
        objFun = getappdata(handles.guiMassRedistributionCheck_gui, 'objFun');
        
        CorrHistory.Alpha{optimValues.iteration+1} = Alpha;
        CorrHistory.MAC{optimValues.iteration+1} = MAC;
        CorrHistory.COMAC{optimValues.iteration+1} = COMAC;
        CorrHistory.anaFreq{optimValues.iteration+1} = meshData.freq(:,1);
        CorrHistory.anaModes{optimValues.iteration+1} = meshData.z;
        CorrHistory.pairedModes{optimValues.iteration+1} = meshData.pairedModes;
        CorrHistory.pairedMAC{optimValues.iteration+1}  = meshData.pairedMAC;
        CorrHistory.obj{optimValues.iteration+1} = obj;
        CorrHistory.objFun{optimValues.iteration+1} = objFun;
        
        setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);    
        
        MassPlot(handles, state);
                
        DynamicsPlot(handles);
        
%         ModePlot(handles); 
    case 'done'
         %get app data
        Alpha = getappdata(handles.guiMassRedistributionCheck_gui, 'Alpha');
        meshData = getappdata(handles.guiMassRedistributionCheck_gui, 'meshData');
        MAC = getappdata(handles.guiMassRedistributionCheck_gui, 'MAC');
        COMAC = getappdata(handles.guiMassRedistributionCheck_gui, 'COMAC');
        obj = getappdata(handles.guiMassRedistributionCheck_gui, 'obj');
        objFun = getappdata(handles.guiMassRedistributionCheck_gui, 'objFun');
        
        CorrHistory.Alpha{end+1} = Alpha;
        CorrHistory.MAC{end+1} = MAC;
        CorrHistory.COMAC{end+1} = COMAC;
        CorrHistory.anaFreq{end+1} = meshData.freq(:,1);
        CorrHistory.anaModes{end+1} = meshData.z;
        CorrHistory.pairedModes{end+1} = meshData.pairedModes;
        CorrHistory.pairedMAC{end+1}  = meshData.pairedMAC;
        CorrHistory.obj{end+1} = obj;
        CorrHistory.objFun{end+1} = objFun;
        
        setappdata(handles.guiMassRedistributionCheck_gui, 'CorrHistory', CorrHistory);   
        
        MassPlot(handles, state);
                
        DynamicsPlot(handles);
end
  
stop = false;
