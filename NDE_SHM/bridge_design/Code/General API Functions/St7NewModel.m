function St7NewModel(uID, ModelPath, ModelName, ScratchPath, Units)
%% Create ST7 model file, set options, and save
ModelPathName = [ModelPath '\' ModelName '.st7']; 
iErr = calllib('St7API','St7NewFile', uID, ModelPathName, ScratchPath);
HandleError(iErr);
iErr = calllib('St7API', 'St7SaveFile', uID);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetUnits', uID, Units);
HandleError(iErr);

end %NewModel