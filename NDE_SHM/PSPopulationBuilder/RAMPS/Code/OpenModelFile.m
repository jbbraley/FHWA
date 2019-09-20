function OpenModelFile(uID, ModelPath, ModelName, ScratchPath)
ModelPathName = [ModelPath ModelName];
iErr = calllib('St7API', 'St7OpenFile', uID, ModelPathName, ScratchPath);
HandleError(iErr);
end % OpenModelFile()