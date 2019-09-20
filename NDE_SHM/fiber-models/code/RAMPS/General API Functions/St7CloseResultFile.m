function LiveLoadSolver(uID, Options, ModelName, ModelPath, Node, Parameters)
global kNormalFreedom stLinearStaticSolver smBackgroundRun
global rnAMD stSparse

%% Set Freedom Case
iErr = calllib('St7API', 'St7SetFreedomCaseType', uID, 1, kNormalFreedom);
HandleError(iErr);

% %% Deck, Barrier, and Sidewalk Stiffness
% % Barriers
% % If Barrier Composite Action is turned off, make barrier stiffness
% % negligeable. 
% % if Parameters.Barrier.CompositeDesign ~= 1
%     for i = Parameters.Barrier.St7PropNum(1) : Parameters.Barrier.St7PropNum(2)
%         Doubles = [5 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
%         iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, Doubles);
%         HandleError(iErr);
%     end
% % end
% 
% % Give Deck new stiffness
% Doubles = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
% iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 1, Doubles);
% HandleError(iErr);
% 
% % If Sidewalk composite action is turned off make sidewalk stiffness
% % negligeable.
% % if Parameters.Sidewalk.CompositeDesign ~= 1
%     Doubles = [5 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
%     iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, Doubles);
%     HandleError(iErr);
% % end

%% Delete Existing Live Load Cases
NumCase = 0;
[iErr, NumCase] = calllib('St7API', 'St7GetNumLoadCase', uID, NumCase);
HandleError(iErr);

if NumCase >= 2
    for i=2:NumCase
        j = 2;
        iErr = calllib('St7API', 'St7DeleteLoadCase', uID, j);
        HandleError(iErr);
    end
end

%% Create Load Cases
LoadCase = 2;
LoadCase = CreateTruckLoadPath(uID, Parameters, Options, Node, LoadCase);


% Get Number of load Cases
NumLoadCase = 0;
[iErr, NumLoadCase] = calllib('St7API', 'St7GetNumLoadCase', uID, NumLoadCase);
HandleError(iErr);

% Result File name
LiveLoadResultPath = [ModelPath ModelName '_LL.lsa'];
iErr = calllib('St7API', 'St7SetResultFileName', uID, LiveLoadResultPath);
HandleError(iErr);

% Set Load Cases to Be Run
for i = 2:NumLoadCase
    iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, i, 1);
    HandleError(iErr);
end

 % Call Solver
iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
HandleError(iErr);
end % LiveLoadSolver()