function DeadLoadSolver(uID, ModelName, ModelPath, Node, Parameters)
global kAccelerations kNormalFreedom stSparse rnAMD
global stLinearStaticSolver smBackgroundRun

% Get Number of Properties
NumProp = zeros(4,1);
LastProp = zeros(4,1);
[iErr, NumProp, LastProp] = calllib('St7API', 'St7GetTotalProperties', uID, NumProp, LastProp);
HandleError(iErr);

%% Static Solver Options
iErr = calllib('St7API', 'St7SetFreedomCaseType', uID, 1, kNormalFreedom);
HandleError(iErr);

% iErr = calllib('St7API', 'St7SetLoadCaseName', uID, 1, 'Dead Load');
% HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseType', uID, 1, kAccelerations);
HandleError(iErr);
Defaults = [0, 0, 0, 0, 0, 0, -386.09, 0, 0, 0, 0, 0, 0];
iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, 1, Defaults);
HandleError(iErr);
% Accelerations applied only to structural mass
iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID,1, 1, 0);
HandleError(iErr);
iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, 1, 1);
HandleError(iErr);

%% User inputted Parameters
% NewBeamI = Parameters.Rating.BeamI; %Use GUI to assign I
% 
% Doubles = zeros(1,11);
% Int = 0;
% [iErr,Int, Doubles] = calllib('St7API', 'St7GetBeamSectionPropertyData', uID, 5, Int, Doubles);
% HandleError(iErr);
% Doubles(3) = NewBeamI;
% [iErr] = calllib('St7API', 'St7SetBeamSectionPropertyData', uID, 5, Int, Doubles);
% HandleError(iErr);
% 
% % E of the diaphragms
DoublesBm = zeros(1,9);
% NewDiaE = Parameters.Rating.DiaE; %Use GUI to assign E
[iErr, DoublesDia_old] = calllib('St7API', 'St7GetBeamMaterialData', uID, 6, DoublesBm);
HandleError(iErr);
% DoublesDia_new = [NewDiaE DoublesDia_old(2:end)]; 
% iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, 6, DoublesDia_new);
% HandleError(iErr);
% 
% % E of the Deck
% NewDeckE = 57000*sqrt(Parameters.Rating.DeckFc); %Use GUI to assign E

%% Deck Dead Load
DeadLoadType = 1;

% Make Barrier Stiffness and Densities Negligable
[iErr, DoublesBarr_old] = calllib('St7API', 'St7GetBeamMaterialData', uID, Parameters.Barrier.St7PropNum(1), DoublesBm);
HandleError(iErr);
DoublesBarr_new = [5 DoublesBarr_old(2:3) 0 DoublesBarr_old(5:end)]; %[5 1659.52 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
for i=Parameters.Barrier.St7PropNum   
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, DoublesBarr_new);
    HandleError(iErr);
end


DoublesPl = zeros(1,8);
% Sidewalk Stiffness and Density Negligable 
[iErr, DoublesSW_old] = calllib('St7API', 'St7GetPlateIsotropicMaterial', uID, Parameters.Sidewalk.St7PropNum, DoublesPl);
HandleError(iErr);
DoublesSW_new = [5 DoublesSW_old(2) 0 DoublesSW_old(4:end)]; %[5 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Sidewalk.St7PropNum, DoublesSW_new);
HandleError(iErr);

% Deck Stiffness Negligable 
[iErr, DoublesDeck_old] = calllib('St7API', 'St7GetPlateIsotropicMaterial', uID, Parameters.Deck.St7PropNum, DoublesPl);
HandleError(iErr);
DoublesDeck_new = [5 DoublesDeck_old(2:end)]; %[5 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Deck.St7PropNum, DoublesDeck_new);
HandleError(iErr);


% Run Solver
DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];
iErr = calllib('St7API', 'St7SetResultFileName', uID, DeadLoadResultPath);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
HandleError(iErr);

%% Superimposed Dead Load
 DeadLoadType = 2;

% Make Barrier Densities Normal

DoublesBarr_new = [5 DoublesBarr_old(2:end)]; %[5 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
for i=Parameters.Barrier.St7PropNum
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, DoublesBarr_new);
    HandleError(iErr);
end


% Sidewalk Density Normal 
DoublesSW_new = [5 DoublesSW_old(2:end)]; %[5 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Sidewalk.St7PropNum, DoublesSW_new);
HandleError(iErr);

% Set Deck/Dia stiffness
DeckE = Parameters.Deck.E;
DiaE = Parameters.Dia.E;

% Deck Stiffness as prescribed and density to zero
DoublesDeck_new = [DeckE DoublesDeck_old(2) 0 DoublesDeck_old(4:end)]; %[DeckE 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Deck.St7PropNum, DoublesDeck_new);
HandleError(iErr);

% Make beam and diaphragm densities zero
[iErr, DoublesBm_old] = calllib('St7API', 'St7GetBeamMaterialData', uID, Parameters.Beam.St7PropNum, DoublesBm);
HandleError(iErr);
DoublesBm_new = [DoublesBm_old(1:3) 0 DoublesBm_old(5:end)]; %[Parameters.Beam.E 16030 0.25 0 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.St7PropNum, DoublesBm_new);
HandleError(iErr);

[iErr, DoublesBmCP_old] = calllib('St7API', 'St7GetBeamMaterialData', uID, Parameters.Beam.CP.St7PropNum, DoublesBm);
HandleError(iErr);
DoublesBmCP_new = [DoublesBmCP_old(1:3) 0 DoublesBmCP_old(5:end)]; %[Parameters.Beam.E 16030 0.25 0 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.CP.St7PropNum, DoublesBmCP_new);
HandleError(iErr);

DoublesDia_new = [DiaE DoublesDia_old(2:3) 0 DoublesDia_old(5:end)]; %[DiaE 16030 0.25 0 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Dia.St7PropNum, DoublesDia_new);
HandleError(iErr);


% Run Solver
DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];
iErr = calllib('St7API', 'St7SetResultFileName', uID, DeadLoadResultPath);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
HandleError(iErr);

% Set New sidewalk and barrier stiffness parameters
% if Parameters.Rating.SidewalkComp
%     % If composite action on set to actual stiffness
SWE = Parameters.Sidewalk.E;
% else
%     SWE = 5; % Negligeable
% end
% if Parameters.Rating.BarrierComp
%     % If composite action on make stiffness actual
BarrierE = Parameters.Barrier.E;
% else
%     BarrierE = 5; % Otherwise negligeable
% end

%% Overlay Dead Load (Stiffness participation of sidewalks and barriers)
if Parameters.Deck.WearingSurface ~=0
    DeadLoadType = 3;
    
    % Accelerations applied to non-structural mass
    iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID,1, 1, 1);
    HandleError(iErr);

    % Turn on sidewalk stiffness and set density to zero
        DoublesSW_new = [SWE DoublesSW_old(2) 0 DoublesSW_old(4:end)]; %[SWE 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, DoublesSW_new);
    HandleError(iErr);

    % Turn on Barrier Stiffness and set density to zero
    
    DoublesBarr_new = [BarrierE DoublesBarr_old(2:3) zeros(1,2) DoublesBarr_old(5:end)]; %[BarrierE 1659.52 0.2 0 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    for i= Parameters.Barrier.St7PropNum
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, DoublesBarr_new);
        HandleError(iErr);
    end
    


    % Run Solver
    DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];
    iErr = calllib('St7API', 'St7SetResultFileName', uID, DeadLoadResultPath);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
    HandleError(iErr);
end

%% Set Deck and Steel Densities Back to Normal
DoublesDeck_new = [DeckE DoublesDeck_old(2:end)]; %[DeckE 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Deck.St7PropNum, DoublesDeck_new);
HandleError(iErr);

% DoublesBm_new = [Parameters.Beam.E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.St7PropNum, DoublesBm_old);
HandleError(iErr);

iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.CP.St7PropNum, DoublesBmCP_old);
HandleError(iErr);

DoublesDia_new = [DiaE DoublesDia_old(2:end)]; %[DiaE 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Dia.St7PropNum, DoublesDia_new);
HandleError(iErr);

%% Set Sidewalk and Barrier and Deck densities back to normal
DoublesBarr_new = [BarrierE DoublesBarr_old(2:end)]; %[BarrierE 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
for i= Parameters.Barrier.St7PropNum
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, i, DoublesBarr_new);
    HandleError(iErr);
end

DoublesSW_new = [SWE DoublesSW_old(2:end)]; %[SWE 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Sidewalk.St7PropNum, DoublesSW_new);
HandleError(iErr);

DoublesDeck_new = [DeckE DoublesDeck_old(2:end)]; %[DeckE 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.Deck.St7PropNum, DoublesDeck_new);
HandleError(iErr);

% Save File
% iErr = calllib('St7API', 'St7SaveFile', uID);
% HandleError(iErr);

end % DeadLoadAnalysis()