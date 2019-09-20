function [Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start)
global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU
clc;

% Load St7 if needed
if St7Start
    InitializeSt7();
end

% Add subfolders to path
addpath(genpath(cd));

%% User Input
% St7 Options
if ~isdir('C:\Temp\')
    mkdir('C:\Temp\');
end

%% Parameters
if isempty(Parameters)
    % St7 Defaults
    Parameters.Barrier.St7PropNum = [3,4];
    Parameters.compAction.St7PropNum = 9;
    Parameters.Beam.St7PropNum = 5;
    Parameters.Beam.CP.St7PropNum = 8;
    Parameters.Dia.St7PropNum = 6;
    
    %% Options for Structure
    Parameters.Geo = 'Adv';
    Parameters.Spans = 1;
    
    Parameters.Design.maxDelta = 800;
    
    Parameters.Beam.Fy = 50000;
    Parameters.Deck.fc = 4000;
    
    Parameters.compAction.Ix = 1000000; % in^4 arbitrarily high number to simulate rigid link
    
    Parameters.Barrier.fc = 4000;
    Parameters.Sidewalk.fc = 4000;
    
    Parameters.Dia.Assign = 'Auto';
    
    Parameters.Beam.E = 29000000;
    Parameters.Dia.E = 29000000;
    
    Parameters.Overlay.exist = 0;
    
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
    
    Parameters.Beam.Updating.Ix.Update = 0;
    Parameters.Deck.Updating.fc.Update = 0;
    Parameters.compAction.Updating.Ix.Update = 0;
    Parameters.Dia.Updating.E.Update = 0;
    Parameters.Barrier.Updating.fc.Update = 0;
    Parameters.Sidewalk.Updating.fc.Update = 0;
    
    Parameters.Beam.Updating.Ix.Init = 0;
    Parameters.Deck.Updating.fc.Init = 0;
    Parameters.compAction.Updating.Ix.Init = 0;
    Parameters.Dia.Updating.E.Init = 0;
    Parameters.Barrier.Updating.fc.Init = 0;
    Parameters.Sidewalk.Updating.fc.Init = 0;
    
    Parameters.Updating.ModelDimUpdate = 0;
    
    Parameters.Sidewalk.Updating.fc = 0;
    Parameters.Barrier.Updating.fc = 0;
end

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

% Choose modeling options
Options.Modeling.MinMeshSize = 8;
Options.Modeling.AvgMeshSize = 12;

% Spans
Options.Spans = 3;

Options.St7.ScratchPath = 'C:\Temp\';
Options.St7.Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];
Options.St7.uID = 1;

Options.LoadPath.RelTolerance = 0.001;
Options.LoadPath.MinLaneWidth = 144;
Options.LoadPath.Divisions = 1;
Options.LoadPath.Length = 0.1;

Options.modelOpen = 0;

Options.handles = [];

Options.SaveDir = 'D:\My Documents\RAMPS\';

Options.Geo.Barrier.Width = 12; 
Options.Geo.Barrier.Height = 27;
Options.Geo.Sidewalk.Height = 10;
Options.Geo.DeckThick = 8;

Options.Default.CoverPlateLength = 0;
Options.Default.GirderSpacing = 72;
Options.Default.Composite = 1;
Options.Default.Spans = 1;

Options.RolledGirder.Var = 0.2;

Options.Default.TransSpring = 1000;
Options.Default.RotSpring = 10000;

Options.Correlation.Method = 'Least Squares';

Options.Correlation.freqWeight = [];

end %InitializeRAMPS():