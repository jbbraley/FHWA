function Parameters = FEALoadRating(uID, Parameters, Options, Node, guiState)
% Assign Variables
ModelPath = Options.St7.ScratchPath;
ModelName = Options.TempFileName;
Code = Parameters.Rating.Code;

%% Solver Options
% Set up defualt freedom case
FCaseNum = 1;
SetDefaultFreedomCase(uID, FCaseNum);

% Set Solver Options
if Options.LoadRating.ShearRating % if Node results mitakenly off, set node reults on for shear rating
   Options.Solver.LSA.Entity.srNodeReaction = 1; 
else
   Options.Solver.LSA.Entity.srNodeReaction = 0;
end
St7SetLSASolverOptions(uID, Parameters, Options); 

%% General Load Rating Parameters
[Parameters, Parameters.Rating.(Code)] = AASHTOLoadRating(Parameters.Rating.(Code),Parameters);
% Truck loads
Parameters.Rating.(Code) = GetTruckLoads(Parameters.Rating.(Code));

%% Dead Load
% Notification Panel
if guiState  
    msg = 'Retrieving Dead Load Responses...';
    UpdateNotificationPanel(Options.handles.RAMPS_gui.listboxNotificationPanel, msg, 'new');
end

% Run Dead Loads
DLCase = 2;
DeadLoadSolver(uID, ModelName, ModelPath, Parameters, DLCase, FCaseNum);

% Run Dead Load Results
if exist([ModelPath ModelName '_1.lsa'],'file') == 2
    DLStart = 1;
    [DLResults] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters, Options, DLStart);
    Parameters.Rating.(Code).FEM.DLR = DLResults;
end

%% Live Load
% Notification Panel
if guiState    
    msg = 'Retrieving Live Load Responses...';
    UpdateNotificationPanel(Options.handles.RAMPS_gui.listboxNotificationPanel, msg, 'new');
end

% Run Live Load Solver
LLCase = 3;
LiveLoadSolver(uID, ModelName, ModelPath, Node, Parameters, Options, Parameters.Rating.(Code), LLCase, FCaseNum);

% Get Live Load Results
if exist([ModelPath ModelName '_LL.lsa'],'file') == 2
    LLStart = 3;
    [LLResults] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters, Options, Parameters.Rating.(Code), LLStart);
    Parameters.Rating.(Code).FEM.LLR = LLResults;
end

%% Rating Factor Calc
% Notification Panel
if guiState 
    msg = 'Computing Rating Factors...';
    UpdateNotificationPanel(Options.handles.RAMPS_gui.listboxNotificationPanel, msg, 'new');
end

% Single Line
Parameters.Rating.(Code).SL.Int = GetRatingFactor(Parameters.Beam.Int,Parameters.Demands.Int.SL,Parameters,'Int');
Parameters.Rating.(Code).SL.Ext = GetRatingFactor(Parameters.Beam.Ext,Parameters.Demands.Ext.SL,Parameters,'Ext');

% FEA 
if Parameters.Rating.(Code).NumLane <= 10
    [Parameters, Parameters.Rating.(Code).FEM] = FEMRatingFactors(Parameters,Parameters.Rating.(Code),Code);
end
end