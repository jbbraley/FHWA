function St7OpenModelFile(uID, PathName, FileName, ScratchPath)
ModelPathName = [PathName FileName '.st7'];
iErr = calllib('St7API', 'St7OpenFile', uID, ModelPathName, ScratchPath);
HandleError(iErr);
end