function St7CloseResultFile(uID)

iErr= calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);
    
end %St7CloseResultFile