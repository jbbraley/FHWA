function CloseResultFile(uID)
try
    calllib('St7API', 'St7CloseResultFile', uID);
catch
end
end