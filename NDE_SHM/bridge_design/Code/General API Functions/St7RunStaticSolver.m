function St7RunStaticSolver(uID, resultPath)
global stSparse rnAMD stLinearStaticSolver smBackgroundRun

iErr = calllib('St7API', 'St7SetResultFileName', uID, resultPath);
HandleError(iErr);

iErr = calllib('St7API', 'St7SetSolverScheme', uID, stSparse);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetSolverSort', uID, rnAMD);
HandleError(iErr);
iErr = calllib('St7API', 'St7RunSolver', uID, stLinearStaticSolver, smBackgroundRun, 1);
HandleError(iErr);

end % CreateLoadCase()