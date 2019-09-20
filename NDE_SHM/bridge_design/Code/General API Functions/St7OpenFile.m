function St7OpenFile(uID, FilePath, ScratchPath)


iErr = calllib('St7API', 'St7OpenFile', uID, FilePath, ScratchPath);
HandleError(iErr);
    
end %St7OpenFile