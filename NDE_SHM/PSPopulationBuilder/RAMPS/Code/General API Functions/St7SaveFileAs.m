function St7SaveFileAs(uID, Pathname, Filename)

ModelPathName = [Pathname Filename '.st7'];
iErr = calllib('St7API', 'St7SaveFileTo', uID, ModelPathName);
HandleError(iErr);
end
