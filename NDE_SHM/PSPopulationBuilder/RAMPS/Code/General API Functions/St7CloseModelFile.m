function St7CloseModelFile(uID)
try
% close file
iErr = calllib('St7API','St7CloseFile', uID);
HandleError(iErr);
catch
end
end % CloseModelFle()