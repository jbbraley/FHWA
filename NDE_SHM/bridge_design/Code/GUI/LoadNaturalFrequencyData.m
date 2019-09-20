function meshData = LoadNaturalFrequencyData(Options, meshData, ResultNodes)
% get data from root
if isempty(Options)
    Options = getappdata(0,'Options');
end
if isempty(meshData)
    meshData = getappdata(0,'meshData');
end
        
% run solver
ModelPath = Options.St7.ScratchPath;
ModelName = Options.TempFileName;
uID = Options.St7.uID;
St7RunNaturalFrequencySolver(uID, ModelPath, ModelName, Options);

% get results
[St7Mode, St7Disp] = St7GetNaturalFrequencyResults(uID,ModelPath,ModelName,ResultNodes);

% save data to root
meshData.U = St7Disp;
meshData.freq = St7Mode;
setappdata(0,'meshData',meshData);
end