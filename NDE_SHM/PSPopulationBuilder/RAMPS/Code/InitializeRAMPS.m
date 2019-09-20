%% (10/14/2014 NPR) Added code to generate path and add subfolders

function [Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start)
global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU
% clc;

% Add subfolders to path
% addpath(genpath(cd));

filename = mfilename('fullpath');
dirind = find(filename=='\',1,'last')-1;
addpath(genpath(filename(1:dirind))); % generate path for toolbox and subfolders
cd(filename(1:dirind));

% Load St7 if needed
if St7Start
    InitializeSt7(1);
end

if isempty(Options)
    % Default save path
    if ~exist([getenv('USERPROFILE') '\RAMPS\'],'dir')
        mkdir(getenv('USERPROFILE'), '\RAMPS\');
    end
    Options.SaveDir = [getenv('USERPROFILE') '\RAMPS\'];
    % default temp dir
    if ~exist([getenv('USERPROFILE') '\RAMPS\tmp\'],'dir')
        mkdir([getenv('USERPROFILE') '\RAMPS\'], '\tmp\');
    end
    Options.St7.ScratchPath = [getenv('USERPROFILE') '\RAMPS\tmp\'];

    %% Options

    % Choose bridge population
    Options.NBI.State = 'nj';

    % Choose analysis options
    Options.RolledGirder.Var = .1;
    Options.BuildModels = 1;
    Options.Analysis.NumModes = 10;
    Options.Analysis.DistributionFactors = 0;
    Options.Analysis.ModeParticipation = 0;
    Options.Analysis.DeadLoad = 0;
    Options.Analysis.LoadRating = 0;
    Options.Analysis.Disp = 0;

    Options.LoadPath.RelTolerance = 0.001;
    Options.LoadPath.MinLaneWidth = 120;
    Options.LoadPath.Divisions = 3;
    Options.LoadPath.Length = 0.1;
    Options.LoadPath.CrawlSteps = 3;

    Options.LoadRating.ShearRating = 0;

    % Choose modeling options
    Options.Modeling.MinMeshSize = 8;
    Options.Modeling.AvgMeshSize = 12;

    % Mass distribution
    Options.MassCorr.XDiv = 1;
    Options.MassCorr.YDiv = 1;
    Options.MassCorr.numDiv = Options.MassCorr.XDiv*Options.MassCorr.YDiv;
    Options.MassCorr.massMulti = ones(Options.MassCorr.numDiv,1);
    Options.MassCorr.ConstantTotal = ones(Options.MassCorr.numDiv,1);
    Options.Correlation.Method = 'Least Squares';
    Options.Correlation.linDefaults = [1, 0.5, 2];
    Options.Correlation.logDefaults = [0, -3, 3];
    Options.Correlation.stringFreqWeightOpts = {'None'; 'Inverse Order'};
    Options.Correlation.stringFreqWeight = 'None';
    Options.Correlation.deltaFreqWeight = 0;
    Options.Correlation.TolX = 0.001;
    Options.Correlation.TolFun = 0.001;
    Options.Correlation.DiffMinChange = 0.0001;

    % Spans
    Options.Spans = 3;

    Options.FileName = '';
    Options.PathName = '';
    Options.St7.Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];
    Options.St7.uID = 1;

    Options.modelOpen = 0;

    if ~isfield(Options, 'handles')
        Options.handles = [];
    end

    Options.Geo.Barrier.Width = 12; 
    Options.Geo.Barrier.Height = 27;
    Options.Geo.Sidewalk.Height = 10;
    Options.Geo.DeckThick = 8;
    Options.Dia.MinDiaAngle = 40; % minimum degrees between bottom chord 
                                  % and diagonal for cross bracing
                                  % Used for when it auto chooses chevron or
                                  % cross
    Options.Dia.autoConfig = 0;

    Options.Default.CoverPlateLength = 0;
    Options.Default.GirderSpacing = 72;
    Options.Default.Composite = 1;
    Options.Default.Spans = 1;

    Options.RolledGirder.Var = 0.2;

    Options.Default.TransSpring = 1000;
    Options.Default.RotSpring = 10000;

    Options.FileOpen.St7Model = 0;
    Options.FileOpen.Parameters = 0;
    Options.FileOpen.Node = 0;
    Options.FileOpen.Options = 0;
    Options.FileOpen.TestData = 0;
    Options.FileOpen.St7Results = 0;

    Options.GUI.expScale = 5;
    Options.GUI.anaScale = 100;
    Options.GUI.anaModeNum = 1;
    Options.GUI.expModeNum = 1;

    Options.TempFileName = [];

    %% Create Folders for Options St7 Options
    if ~isdir(Options.St7.ScratchPath)
        mkdir(Options.St7.ScratchPath);
    end
    if ~isdir(Options.SaveDir)
        mkdir(Options.SaveDir);
    end

    %% Solver Options
    % LSA Solver --------------------------------------------------------------
    % Entity Results
    % 1 - Solve for entity result type
    % 0 - Dont solve for
    % Uses St7SetEntityResult API command
    Options.Solver.LSA.Entity.srBeamForce = 1;
    Options.Solver.LSA.Entity.srNodeReaction = 1;
    Options.Solver.LSA.Entity.srElementNodeForce = 0;
    Options.Solver.LSA.Entity.srPlateStress = 0;
    Options.Solver.LSA.Entity.srPlateStrain = 0;

    % LSA Solver Defaults
    Options.Solver.LSA.Defaults.spIncludeLinkReactions = 1;

    % LSA Solver Options
    Options.Solver.LSA.SetScheme = 'stSparse';
    Options.Solver.LSA.SetSort = 'rnAMD';
end

%% Parameters
if isempty(Parameters)
%     switch structureType
%         case 'Steel'
%             Parameters.structureType = structureType;
%             update = [
%         case 'Prestressed'
%             Parameters.structureType = structureType;
%         otherwise
%             Parameters.structureType = '';
%     end
    default = [];
    
    % Model Name
    Parameters.ModelName = '';
    
    %Structure Type
    Parameters.structureType = '';
    
    % ModelType        
    Parameters.ModelType = '';   
    
    % Preallocate
    Parameters.Config = [];
    Parameters.Design = [];
    Parameters.Demands = [];
    Parameters.Beam = [];
    Parameters.Deck = [];
    Parameters.Updating = [];
    
    % Options for Structure
    Parameters.Geo = 'Adv';  
    
    % Length Option
    Parameters.LengthOption = 'None';  
    
    % Bridge Configuration Parameters
    Parameters.Spans = default;
    Parameters.Length = default;
    Parameters.EffectiveLength = default;
    Parameters.RoadWidth = default;
    Parameters.Width = default;
    Parameters.NumLane = default;
    Parameters.SkewNear = default;
    Parameters.SkewFar = default;
    Parameters.NumDia = default;
    Parameters.NumGirder = default;
    Parameters.GirderSpacing = default;
    Parameters.TotalWidth = default;
    Parameters.Overhang = default;
    Parameters.TotalLeftSidewalk = default;
    Parameters.TotalRightSidewalk = default; 
    
    % Sidewalk
    Parameters.Sidewalk.fc = 4000; 
    Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);
    Parameters.Sidewalk.density = 0.0868;
    
    % Barrier
    Parameters.Barrier.fc = 4000; 
    Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);
    Parameters.Barrier.density = 0.0868;
    
    % Deck
    Parameters.Deck.fc = 4000;
    Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);
    Parameters.Deck.density = 0.0868;
    
    % Beam
    Parameters.Beam.Type = default;
    Parameters.Beam.Fy = 50000;
    Parameters.Beam.E = 29000000;    
    Parameters.Beam.fc = 8000;
    Parameters.Beam.PSSteel.Fu = 270000;
    Parameters.Beam.Int.Des = default;
    Parameters.Beam.Ext.Des = default;
    Parameters.Beam.density = 0.2836;
    Parameters.Beam.Encase = [0,0]; %[width, height]
    Parameters.Beam.connectionPct = 0.06;
    
    % Diaphragm
    Parameters.Dia.Type = '';
    Parameters.Dia.Config = '';
    Parameters.Dia.SectionName = '';  
    Parameters.Dia.E = 29000000;
    Parameters.Dia.fc = 4000;  
    Parameters.Dia.Fy = 50000;
    Parameters.Dia.autoType = 1;
    Parameters.Dia.autoConfig = 1;
    Parameters.Dia.autoSection = 1;
    
    % Overlay
    Parameters.Deck.WearingSurface = 0; 
    
    % CompAction
    Parameters.compAction.Ix = 1000000; % in^4 arbitrarily high number to simulate rigid link 
    
    % Design/Single Line Structure
    Parameters.Design = default;  
    
    % Model
    Parameters.Model = default; 
    
    % Bearings
    Parameters.Bearing = default; 
    
    % Updating
    Parameters.Updating = default; 
    
    % Rating
    Parameters.Rating = default;
    Parameters.Rating.LRFD.CB = 1;
    Parameters.Rating.ASD.CB = 0; % in there as a placeholder
    Parameters.Rating.LRFD.useCB = 0;
    Parameters.Rating.LRFD.DesignLoad = 'A';
    
    % Max Delta
    Parameters.Design.maxDelta = 800;

    
    %% Options for Bearings
    Parameters.Bearing.Fixed.Update = [0 0 0 0 0 0 0 0];
    Parameters.Bearing.Expansion.Update = [0 0 0 0 0 0 0 0];
    
    Parameters.Bearing.Fixed.Fixity = [1 0 1 0 0 0 1 0];
    Parameters.Bearing.Expansion.Fixity = [0 0 1 0 0 0 1 0];
    
    Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
    Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
    
    Parameters.Bearing.Fixed.Alpha = bsxfun(@times, ones(7,3), [0, -5, 5]); % Nx3 array - columns: [start alpha, min alpha, max alpha]
    Parameters.Bearing.Expansion.Alpha = bsxfun(@times, ones(7,3), [0, -5, 5]);
    
    Parameters.Bearing.Linked = zeros(1,7);
    
    Parameters.Bearing.Type = zeros(1,100); % arbitrarily high number greater than possible # of spans
    
    Parameters.Bearing.Expansion.Spring = zeros(1,7);
    Parameters.Bearing.Fixed.Spring = zeros(1,7);
    
    Parameters.Bearing.Fixed.Index = zeros(1,7);
    Parameters.Bearing.Expansion.Index = zeros(1,7);
    
    %% Parameters for Updating
    % linear scale
    Parameters.Beam.Updating.Ix.Alpha = [1, 0.75, 1.25]; % 1x3 array - columns: [start alpha, min alpha, max alpha]
    Parameters.Deck.Updating.fc.Alpha = [1, 0.75, 1.25];
    Parameters.Dia.Updating.E.Alpha = [1, 0.75, 1.25];
    % log scale
    Parameters.compAction.Updating.Ix.Alpha = [0, -10, 0];
    Parameters.Barrier.Updating.fc.Alpha = [0, -10, 0];
    Parameters.Sidewalk.Updating.fc.Alpha = [0, -10, 0];
    
    Parameters.Deck.Updating.fc.Update = 0;
    Parameters.compAction.Updating.Ix.Update = 0;
    Parameters.Dia.Updating.E.Update = 0;
    Parameters.Barrier.Updating.fc.Update = 0;
    Parameters.Sidewalk.Updating.fc.Update = 0;
    Parameters.Beam.Updating.Ix.Update = 0;
    
    Parameters.Deck.Updating.fc.Scale = 'lin';
    Parameters.compAction.Updating.Ix.Scale = 'log';
    Parameters.Dia.Updating.E.Scale = 'lin';
    Parameters.Barrier.Updating.fc.Scale = 'log';
    Parameters.Sidewalk.Updating.fc.Scale = 'log';
    Parameters.Beam.Updating.Ix.Scale = 'lin';
    
    Parameters.Updating.ModelDimUpdate = 0;
end
    % St7 Defaults
    if isfield(Parameters, 'St7Prop')
        Parameters = rmfield(Parameters, 'St7Prop');
    end
    Parameters.St7Prop(1).propName = 'Deck';
    Parameters.St7Prop(1).fieldName = 'Deck';
    Parameters.St7Prop(1).propType = 'Shell';
    Parameters.St7Prop(1).elmtNums = [];
    Parameters.St7Prop(1).St7PropNum = 1;
    Parameters.St7Prop(1).MatData = [Parameters.Deck.E 0.2 Parameters.Deck.density 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    Parameters.St7Prop(1).MatName = 'Deck Concrete';
    Parameters.St7Prop(1).AlphaScale = 'lin';
    Parameters.St7Prop(1).Alphas = Options.Correlation.([(Parameters.St7Prop(1).AlphaScale) 'Defaults']);
    Parameters.St7Prop(1).UpdateGroup = 1;
    Parameters.St7Prop(1).update = 1;
    Parameters.St7Prop(1).updateType = 'fc';
    Parameters.St7Prop(1).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Sidewalk';
    Parameters.St7Prop(end).fieldName = 'Sidewalk';
    Parameters.St7Prop(end).propType = 'Shell';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 2;
    Parameters.St7Prop(end).MatData = [Parameters.Sidewalk.E 0.2 Parameters.Sidewalk.density 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    Parameters.St7Prop(end).MatName = 'Sidewalk Concrete';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 2;
    Parameters.St7Prop(end).update = 1;
    Parameters.St7Prop(end).updateType = 'fc';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Barrier';
    Parameters.St7Prop(end).fieldName = 'Barrier';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 1;
    Parameters.St7Prop(end).MatData = [Parameters.Barrier.E 1659.52 0.2 Parameters.Barrier.density 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    Parameters.St7Prop(end).MatName = 'Barrier Concrete';
    Parameters.St7Prop(end).AlphaScale = 'log';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 3;
    Parameters.St7Prop(end).update = 1;
    Parameters.St7Prop(end).updateType = 'fc';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Ext Girder';
    Parameters.St7Prop(end).fieldName = 'Beam.Ext';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 2;
    Parameters.St7Prop(end).MatData =  [Parameters.Beam.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'Ext Girder Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 4;
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'Ix';
    Parameters.St7Prop(end).St7SolveFor = 1;
    
    Parameters.St7Prop(end+1).propName = 'Int Girder';
    Parameters.St7Prop(end).fieldName = 'Beam.Int';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 3;
    Parameters.St7Prop(end).MatData =  [Parameters.Beam.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'Int Girder Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end+0).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 4;
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'Ix';
    Parameters.St7Prop(end).St7SolveFor = 1;
    
    Parameters.St7Prop(end+1).propName = 'Ext Girder Coverplate';
    Parameters.St7Prop(end).fieldName = 'Beam.Ext.CoverPlate';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 4;
    Parameters.St7Prop(end).MatData =  [Parameters.Beam.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'Ext Girder CP Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 4;
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'Ix';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Int Girder Coverplate';
    Parameters.St7Prop(end).fieldName = 'Beam.Int.CoverPlate';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 5;
    Parameters.St7Prop(end).MatData =  [Parameters.Beam.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'Int Girder CP Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 4;
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'Ix';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'End Diaphragm';
    Parameters.St7Prop(end).fieldName = 'Dia';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 6;
    Parameters.St7Prop(end).MatData =  [Parameters.Dia.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'End Dia Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = [];
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'E';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Int Diaphragm';
    Parameters.St7Prop(end).fieldName = 'Dia';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 7;
    Parameters.St7Prop(end).MatData =  [Parameters.Dia.E 16030 0.25 Parameters.Beam.density 6.5*10^(-6) 0 0 0.0086664 0.1111];
    Parameters.St7Prop(end).MatName = 'Int Dia Steel';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 6;
    Parameters.St7Prop(end).update = 0;
    Parameters.St7Prop(end).updateType = 'E';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Comp Action';
    Parameters.St7Prop(end).fieldName = 'compAction';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 8;
    Parameters.St7Prop(end).MatData = [Parameters.Beam.E 10000000 0 0 0 0 0 0 0];
    Parameters.St7Prop(end).MatName = 'Comp Action Link';
    Parameters.St7Prop(end).AlphaScale = 'log';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = 7;
    Parameters.St7Prop(end).update = 1;
    Parameters.St7Prop(end).updateType = 'Ix';
    Parameters.St7Prop(end).St7SolveFor = 0;
    
    Parameters.St7Prop(end+1).propName = 'Girder Concrete';
    Parameters.St7Prop(end).fieldName = 'Beam';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 9;
    Parameters.St7Prop(end).MatData =  [Parameters.Beam.E 1659.52 0.2 Parameters.Beam.density 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    Parameters.St7Prop(end).MatName = 'PS Girder Concrete';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = [];
    Parameters.St7Prop(end).update = 1;
    Parameters.St7Prop(end).updateType = 'fc';
    Parameters.St7Prop(end).St7SolveFor = 1;
    
    Parameters.St7Prop(end+1).propName = 'Diaphragm Concrete';
    Parameters.St7Prop(end).fieldName = 'Dia';
    Parameters.St7Prop(end).propType = 'Beam';
    Parameters.St7Prop(end).elmtNums = [];
    Parameters.St7Prop(end).St7PropNum = 10;
    Parameters.St7Prop(end).MatData =  [Parameters.Dia.E 1659.52 0.2 Parameters.Beam.density 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    Parameters.St7Prop(end).MatName = 'Concrete Dia';
    Parameters.St7Prop(end).AlphaScale = 'lin';
    Parameters.St7Prop(end).Alphas = Options.Correlation.([(Parameters.St7Prop(end).AlphaScale) 'Defaults']);
    Parameters.St7Prop(end).UpdateGroup = [];
    Parameters.St7Prop(end).update = 1;
    Parameters.St7Prop(end).updateType = 'fc';
    Parameters.St7Prop(end).St7SolveFor = 0;



end %InitializeRAMPS():