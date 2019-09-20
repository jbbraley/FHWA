clc; clear;

[fname, fpath] = uigetfile('*.mat');
% load parameters
load([fpath fname])

 Options = [];
[Parameters, Options] = InitializeRAMPS(Options, Parameters, 1);
InitializeSt7(0);
modelName = fname(1:end-4);
ScratchPath = 'C:\temp';

NewModel(Options.St7.uID, fpath, modelName, ScratchPath, Options.St7.Units)
[Node, Parameters] = ModelGeneration(Options.St7.uID, Options, Parameters);
% save([Path '\Nodes\' modelName '_Node.mat'],'Node','-v7');
% clear('Nodes');

% Save model file
iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
HandleError(iErr);

CloseModelFile(Options.St7.uID);
CloseAndUnload(Options.St7.uID);