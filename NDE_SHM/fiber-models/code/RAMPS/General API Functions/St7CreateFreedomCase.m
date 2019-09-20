function St7CreateLoadCase(uID, LCaseName, LCaseNum, LCaseType, LCaseDefaults, LCaseMass)

iErr = calllib('St7API', 'St7NewLoadCase', uID, LCaseName);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LCaseNum, LCaseType);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LCaseNum, LCaseDefaults);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LCaseNum, LCaseMass(1), LCaseMass(2));
HandleError(iErr);

end % CreateLoadCase()