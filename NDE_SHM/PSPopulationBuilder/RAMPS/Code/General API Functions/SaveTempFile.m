function Options = SaveTempFile(Options)
if ~isempty(Options.TempFileName)
    old_TempFileName = Options.TempFileName;
else
 old_TempFileName = [];
end

% Save new temp file with new name
% Save temp copy of St7 file in workspace and open temp copy
Options.TempFileName = [Options.FileName '_temp'];
St7SaveFileAs(Options.St7.uID, Options.St7.ScratchPath, Options.TempFileName);

% Close Old Temp
St7CloseModelFile(Options.St7.uID);

% Delete Old Temp
if ~isempty(old_TempFileName)
    delete([Options.St7.ScratchPath '\' old_TempFileName '.st7']);
end

% Open New Temp
St7OpenModelFile(Options.St7.uID, Options.St7.ScratchPath,...
    Options.TempFileName, Options.St7.ScratchPath);
end