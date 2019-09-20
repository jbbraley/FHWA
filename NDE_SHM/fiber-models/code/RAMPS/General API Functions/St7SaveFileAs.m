function St7SaveFileAs(uID, PathName, FileName)

ModelPathName = [PathName FileName '.st7'];
iErr = calllib('St7API', 'St7SaveFileTo', uID, ModelPathName);
HandleError(iErr);
end
