function St7Modal = St7RunNaturalFrequencySolver(uID, ModelPath, ModelName, Options)
global stSparse rnAMD stNaturalFrequencySolver smBackgroundRun
%% Call the solver
ModalResultPath = [ModelPath ModelName '.nfa'];
iErr = calllib('St7API', 'St7SetResultFileName', uID, ModalResultPath);
HandleError(iErr);

iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetNFANumModes', uID, Options.Analysis.NumModes);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetNFAModeParticipationCalculate', uID, Options.Analysis.ModeParticipation);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stNaturalFrequencySolver, smBackgroundRun, 1);
HandleError(iErr);
iErr = calllib('St7API', 'St7SaveFile', uID);
HandleError(iErr);
end      % ModalResults()