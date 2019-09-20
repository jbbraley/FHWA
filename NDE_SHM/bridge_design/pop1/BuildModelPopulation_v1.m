% NDE-SHM_BuildModelPopulation
clc
clear
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUT --------------------------------------------------------------

% Directories
Path = 'C:\Users\John B\Projects_Git\FHWA\NDE_SHM\bridge_design';
Path2 = [Path '\pop2'];
addpath(genpath(Path));

% OTHER SET-UP ------------------------------------------------------------
% Load Shapes
load([Path '\Tables\WShapes_Current.mat']);
load([Path '\Tables\CShapes_Current.mat']);
load([Path '\Tables\LShapes_Current.mat']);

% Model Info
Spans = 1;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%%%%%%%%%%%%%%%%%%%%%%%%% CREATE SAMPLE SPACE %%%%%%%%%%%%%%%%%%%%%%%%

% Sampling Parameters
span_length = [50 100 150]*12; %inches
girder_spacing = [6 8 12]*12; %inches
structureType = {'Steel'}; %'Prestressed'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Member SIZING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


n=1;
NN = length(span_length)*length(girder_spacing)*length(structureType);
%% loop through design parameters (full-factorial)
for ii = 1:length(span_length)
    for jj = 1:length(girder_spacing)
        for kk = 1:length(structureType)
            % Initialize Parameters and Options
            Options = [];
            Parameters = [];
            [Parameters, Options] = InitializeRAMPS(Options, Parameters, 0);
            
            % Assign Default Parameters/Options
            Parameters.Spans = Spans;
            Parameters.structureType = structureType{kk};
            
            % SAMPLED PARAMETER ASSIGNMENTS -------------------------------------------
            Length = span_length(ii);
            ExtWidth = 40*12; %in
            Skew = 0;
            GirderSpacing = girder_spacing(jj);
            ModelName = [structureType{kk} '-' num2str(span_length(ii)/12) 'ftx' num2str(girder_spacing(jj)/12) 'ft-spacing'];

            % NumGirder (based on number of girder that fit in road width) 
            Spaces = round(ExtWidth/GirderSpacing);
            NumGirder = Spaces + 1;

            % Adjusted Road width
            AdjustedExtWidth = Spaces*GirderSpacing;

            % Add half girder spacing Overhang
            Width = AdjustedExtWidth + GirderSpacing; % Out-to-out
            Parameters.Overhang = GirderSpacing/2;

            % Parameter Assignments
            Parameters.NumGirder = NumGirder;
            Parameters.GirderSpacing = GirderSpacing;
            Parameters.Length(1:Parameters.Spans,1) = Length; % For two span bridge
            Parameters.SkewNear = Skew;
            Parameters.SkewFar = Skew;
            Parameters.RoadWidth = AdjustedExtWidth;
            Parameters.TotalWidth = AdjustedExtWidth;
            Parameters.Width = Width;

            [Parameters,Options] = MedianModelParameters(Parameters,Options);

            % MEMBER SIZING -----------------------------------------------------------
            switch Parameters.structureType
                case 'Prestressed'
                    Parameters = PSGirderDesign( Parameters );
%                     Parameters.Dia = SetConcreteDiaSection(Parameters);
                case {'steel', 'Steel'}
                   % Get AASHTO design parameters
                    Parameters = AASHTODesign(Parameters, Options); 
                    [Parameters,Parameters.Design.SLG.Int] = GetFEApproximation(Parameters, []);
                    Parameters.Design.SLG.Ext = Parameters.Design.SLG.Int;
                    Parameters = GetAASHTOLLDeflectionRequirement(Parameters);
                    % --------------------------- GIRDER SIZING ---------------------------
                    Section = {'Int';'Ext'};
                    Parameters = GirderSizing(Parameters, Options, Section,CShapes, WShapes, LShapes);
            end
            % save parameters
            save([Path2 '\Parameters\' ModelName '.mat'], 'Parameters', '-v7');
            
            fprintf(['completed bridge ' num2str(n) ' of ' num2str(NN) '\n']);
            n = n+1;
        end
    end
end

% save design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% GET MODELSPACE INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ModelSpace = GetModelInfo(Path);
% save([Path2 '\ModelSpace.mat'],'ModelSpace');   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('population design complete. \n');
