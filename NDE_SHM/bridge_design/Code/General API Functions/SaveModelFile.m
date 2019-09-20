function SaveModelFile(uID)
% Save file
iErr = calllib('St7API', 'St7SaveFile', uID);
HandleError(iErr);

end % SaveModelFile(uID)