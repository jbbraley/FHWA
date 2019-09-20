function St7SetLSASolverOptions(uID, Parameters, Options)
% Sets Options for LSA Solver
% Options Set in InitializeRAMPS
% Options.Solver.LSA containts most solver parameters
% Parameters.St7Prop.St7Solver.LSA contains RAMPS property-specific options

% Solver Options
eval(['global ', Options.Solver.LSA.SetScheme]);
iErr = calllib('St7API', 'St7SetSolverScheme', uID, eval(Options.Solver.LSA.SetScheme));
HandleError(iErr);
eval(['global ', Options.Solver.LSA.SetSort]);
iErr = calllib('St7API', 'St7SetSolverSort', uID, eval(Options.Solver.LSA.SetSort));
HandleError(iErr);

% Default Options
fNames = fieldnames(Options.Solver.LSA.Defaults);
for i = 1:length(fNames)
    eval(['global ', fNames{i}]);
    iErr = calllib('St7API', 'St7SetSolverDefaultsLogical', uID, eval(fNames{i}), Options.Solver.LSA.Defaults.(fNames{i}) );
    HandleError(iErr);
end

% % Property Options
for i = 1:length(Parameters.St7Prop)
    switch Parameters.St7Prop(i).propType
        case 'Beam'
            fName = 'ptBEAMPROP';
        case 'Shell'
            fName = 'ptPLATEPROP';
        case 'Brick'
            fName = 'ptBRICKPROP';
    end
    eval(['global ', fName]);
    
    if Parameters.St7Prop(i).St7SolveFor
        iErr = calllib('St7API', 'St7EnableResultProperty', uID, eval(fName), Parameters.St7Prop(i).St7PropNum);
        HandleError(iErr);
    else
        iErr = calllib('St7API', 'St7DisableResultProperty', uID, eval(fName), Parameters.St7Prop(i).St7PropNum);
        HandleError(iErr);
    end
end

% Result Options
fNames = fieldnames(Options.Solver.LSA.Entity);
for i = 1:length(fNames)
    eval(['global ', fNames{i}]);
    iErr = calllib('St7API', 'St7SetEntityResult', uID, eval(fNames{i}), Options.Solver.LSA.Entity.(fNames{i}));
    HandleError(iErr);
end

% Save File
SaveModelFile(uID);
end % St7SetSolverOptions()