

function RAMPSLauncher(StartOption)
%% Initialize Work Environment
St7Start = 1;
Options = [];
Parameters = [];
[Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

if isempty(StartOption)
    RAMPS(Parameters, Options, []);
elseif strcmp(StartOption, 'GUI')    
    setappdata(0, 'Parameters', Parameters);
    setappdata(0, 'Options', Options)
    RAMPS_gui();
elseif strcmp(StartOption, 'Settlement')
    ParametricValues = LoadParametricValues();
    RAMPS(Parameters, Options, ParametricValues); 
end


end