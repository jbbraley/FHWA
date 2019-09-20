function St7CreateFreedomCase(uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults)

iErr = calllib('St7API', 'St7NewFreedomCase', uID, FCaseName);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetFreedomCaseDefaults', uID, FCaseNum, FCaseDefaults);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetFreedomCaseType', uID, FCaseNum, FCaseType);
HandleError(iErr);

end % CreateFreedomCase()