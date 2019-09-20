function PSForceSolver(Parameters, Options, ModelPath, ModelName )
%PSFORCESOLVER  Applies prestressing force to girders
%
%   A load case is defined with gravitational acceleration turned off
%   P/S Force is applied as well as the moment due to eccentricity
%   The load case is analyzed via a linear static load solver
%
%       Parameters  -   Structure containing meta data
%       Options     -   Structure containing modelling meta data
%       ModelPath   -   String defining the location of the St7 model file
%       ModelName   -   String defining the name of the St7 model file (without '.st7' extension)
%
%   Example:
%       PSForceSolver(Parameters, Option, 'C:\Documents\Models\', 'SampleModel')
%
%   Created 7/15/14
%               John Braley
%

global kNormalFreedom stLinearStaticSolver smBackgroundRun
global rnAMD stSparse

%% Open St7File
uID = Options.St7.uID;
St7OpenFile(Options.St7.uID, [ModelPath ModelName '.st7'], Options.St7.ScratchPath)

%% Set Freedom Case
iErr = calllib('St7API', 'St7SetFreedomCaseType', uID, 1, kNormalFreedom);
HandleError(iErr);

%% Set Load Case
LoadCase = 1;
iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LoadCase, kAccelerations);
HandleError(iErr);
% Make all self weight accelerations zero
Defaults = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LoadCase, Defaults);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LoadCase, 0, 0);
HandleError(iErr);
% Enable load case
iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, 1, 1);
HandleError(iErr);


%% Turn off stiffness of everything except girders
% Get Number of Properties
NumProp = zeros(4,1);
LastProp = zeros(4,1);
[iErr, NumProp, LastProp] = calllib('St7API', 'St7GetTotalProperties', uID, NumProp, LastProp);
HandleError(iErr);

% Make Barrier Stiffness Negligeable
if NumProp(1) == 5
    for i=3:4
        Doubles = [5 1659.52 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, Doubles);
        HandleError(iErr);
    end
end

%Diaphragm Stiffness Negligeable
Doubles = [5 1659.52 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, 6, Doubles);
HandleError(iErr);
        
% Sidewalk Stiffness Negligable 
Doubles = [5 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, Doubles);
HandleError(iErr);

% Deck Stiffness Negligable 
Doubles = [5 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 1, Doubles);
HandleError(iErr);

%% Apply Force and Moment
% Locate Nodes of girder ends
[Ends, ~] = FindGirderBounds(Node);

for ii=1:Parameters.Spans
    % Apply point Forces
    St7ApplyNodeForce(uID, LoadCase, Ends(ii,:),[Parameters.Beam.PSForce 0 0]);
    St7ApplyNodeForce(uID, LoadCase, Ends(ii+1,:),[-Parameters.Beam.PSForce 0 0]);
    % Apply Point Moments
    PSMoment = Parameters.Beam.PSForce*Parameters.Beam.PSEcc;
    St7ApplyNodeMoment(uID, LoadCase, Ends(ii,:),[0 PSMoment 0]);
    St7ApplyNodeMoment(uID, LoadCase, Ends(ii+1,:),[0 -PSMoment 0]);
end

%% Run Solver
% Result File name
PSFResultPath = [ModelPath ModelName '_PSF.lsa'];
iErr = calllib('St7API', 'St7SetResultFileName', uID, PSFResultPath);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
HandleError(iErr);

% %% Return material properties to original state
% % Make Barrier Stiffness Negligeable
% if NumProp(1) == 5
%     for i=3:4
%         Doubles = [Parameters.Barrier.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
%         iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, Doubles);
%         HandleError(iErr);
%     end
% end
% 
% %Diaphragm Stiffness Negligeable
% Doubles = [Parameters.Dia.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
% iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, 6, Doubles);
% HandleError(iErr);
%         
% % Sidewalk Stiffness Negligable 
% Doubles = [Parameters.Sidewalk.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
% iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, Doubles);
% HandleError(iErr);
% 
% % Deck Stiffness Negligable 
% Doubles = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
% iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 1, Doubles);
% HandleError(iErr);
% 
% % Save File
% iErr = calllib('St7API', 'St7SaveFile', uID);
% HandleError(iErr);

end %PSForceSolver

